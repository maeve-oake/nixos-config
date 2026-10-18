"""Process-local upload coordination. No database, network server, or Buildbot imports."""

from __future__ import annotations

from collections import deque
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass, field
import threading
import time
import uuid

TERMINAL = {"complete", "failed", "cancelled"}


@dataclass(eq=False)
class Job:
    path: str
    size: int
    state: str = "queued"
    sent: int = 0
    started: float | None = None
    finished: float | None = None
    attempt: int = 0
    error: str = ""
    output: str = ""
    subscribers: set = field(default_factory=set)
    cancel: threading.Event = field(default_factory=threading.Event)


@dataclass(eq=False)
class Ticket:
    target: str
    publication: str
    state: str = "planning"
    jobs: list = field(default_factory=list)
    cached: int = 0
    upstream: int = 0
    error: str = ""
    summary: str = ""
    # Each step has its own cursor; shared jobs' original output is replayed once.
    logs: list = field(default_factory=list)
    acknowledged: bool = False


@dataclass
class Publication:
    id: str
    key: str
    roots: tuple
    metadata: dict
    tickets: dict
    created: float = field(default_factory=time.time)
    release: object = None
    preparing: bool = True
    finished: float | None = None


class UploadQueue:
    def __init__(self, backend, limits, *, attempts=3, retry_delay=2, history=200, success_ttl=3600):
        if not limits or any(n < 1 for n in limits.values()):
            raise ValueError("Each destination needs a positive transfer limit")
        self.backend, self.limits = backend, dict(limits)
        self.attempts, self.retry_delay, self.history = attempts, retry_delay, history
        self.success_ttl = success_ttl
        self.confirmed = {name: {} for name in limits}
        self.lock = threading.RLock()
        self.publications = {}
        self.keys = {}
        self.jobs = {name: {} for name in limits}
        self.ready = {name: deque() for name in limits}
        self.running = {name: 0 for name in limits}
        self.inflight = {name: {} for name in limits}
        self.planners = ThreadPoolExecutor(max_workers=4, thread_name_prefix="attic-plan")
        self.workers = ThreadPoolExecutor(max_workers=sum(limits.values()), thread_name_prefix="attic-upload")
        self.closed = False
        self.instance = uuid.uuid4().hex

    def submit(self, key, roots, metadata):
        roots = tuple(sorted(set(roots)))
        if not roots or any(not p.startswith("/nix/store/") or "\n" in p for p in roots):
            raise ValueError("Publication roots must be Nix store paths")
        with self.lock:
            if self.closed:
                raise RuntimeError("Upload queue is stopping")
            if key in self.keys:
                pub = self.publications[self.keys[key]]
                if pub.roots != roots:
                    raise ValueError("Publication key reused with different roots")
                return pub.id
            ident = uuid.uuid4().hex
            tickets = {name: Ticket(name, ident) for name in self.limits}
            pub = Publication(ident, key, roots, dict(metadata), tickets)
            self.publications[ident] = pub
            self.keys[key] = ident
            self.planners.submit(self._prepare, pub)
            return ident

    def _prepare(self, pub):
        try:
            release = self.backend.pin(pub.id, pub.roots)
            with self.lock:
                pub.release = release
            closure = self.backend.closure(pub.roots)
            for name, ticket in pub.tickets.items():
                with self.lock:
                    if ticket.state == "cancelled":
                        continue
                started = time.time()
                with self.lock:
                    self._expire_confirmed(started)
                    unknown, reused = [], 0
                    for item in closure:
                        path = item["path"]
                        existing = self.jobs[name].get(path)
                        if path in self.confirmed[name]:
                            reused += 1
                        elif existing and existing.state in {"queued", "uploading"}:
                            existing.subscribers.add(ticket)
                            ticket.jobs.append(existing)
                        else:
                            unknown.append(path)
                try:
                    # No Attic request at all when everything is in flight or
                    # was successfully uploaded within the last hour.
                    plan = self.backend.plan(name, unknown) if unknown else dict(paths=[], cached=0, upstream=0)
                    with self.lock:
                        if ticket.state == "cancelled":
                            continue
                        ticket.cached, ticket.upstream = plan["cached"] + reused, plan["upstream"]
                        summary_plan = dict(plan, cached=ticket.cached,
                                            paths=plan["paths"] + [dict(path=j.path, size=j.size) for j in ticket.jobs])
                        ticket.summary = self.backend.summary(name, summary_plan)
                        ticket.logs.append(ticket.summary)
                        for item in sorted(plan["paths"], key=lambda p: (p["size"], p["path"])):
                            job = self.jobs[name].get(item["path"])
                            # A plan can race an upload's completion. Reuse that
                            # success, but re-upload if a later plan reports eviction.
                            if job is None or job.state in {"failed", "cancelled", "cancelling"} or (
                                job.state == "complete" and job.finished < started
                            ):
                                job = Job(item["path"], item["size"])
                                self.jobs[name][job.path] = job
                            job.subscribers.add(ticket)
                            ticket.jobs.append(job)
                            if job.state in TERMINAL:
                                ticket.logs.append(job.output)
                        ticket.state = "queued"
                        self.ready[name].append(ticket)
                        self._refresh(ticket)
                        self._dispatch(name)
                except Exception as exc:
                    with self.lock:
                        if ticket.state != "cancelled":
                            ticket.state, ticket.error = "failed", str(exc)
                            ticket.logs.append(f"Attic planning failed: {exc}\n")
        except Exception as exc:
            with self.lock:
                for ticket in pub.tickets.values():
                    if ticket.state != "cancelled":
                        ticket.state, ticket.error = "failed", str(exc)
                        ticket.logs.append(f"Attic preparation failed: {exc}\n")
        finally:
            with self.lock:
                pub.preparing = False
                self._settle()

    def _refresh(self, ticket):
        if ticket.state in TERMINAL or ticket.state == "planning":
            return
        if any(j.state == "failed" for j in ticket.jobs):
            # Wait for the rest of this host's paths before releasing its roots.
            ticket.error = "One or more required paths failed to upload"
        if all(j.state in TERMINAL for j in ticket.jobs):
            ticket.state = "failed" if ticket.error else "complete"
        elif any(j.state == "uploading" for j in ticket.jobs):
            ticket.state = "uploading"
        else:
            ticket.state = "queued"

    def _dispatch(self, name):
        ready = self.ready[name]
        while self.running[name] < self.limits[name] and ready and not self.closed:
            ticket = ready.popleft()
            if ticket.state in TERMINAL:
                continue
            job = next((j for j in ticket.jobs if j.state == "queued" and j.path not in self.inflight[name]), None)
            if job is None:
                # A cancelled generation may still be terminating its subprocess.
                if any(j.state == "queued" for j in ticket.jobs):
                    ready.append(ticket)
                    break
                continue
            job.state, job.started = "uploading", time.time()
            self.running[name] += 1
            self.inflight[name][job.path] = job
            if any(j.state == "queued" for j in ticket.jobs):
                ready.append(ticket)
            for subscriber in job.subscribers:
                self._refresh(subscriber)
            self.workers.submit(self._upload, name, job)

    def _upload(self, name, job):
        output = []
        succeeded = False
        try:
            for attempt in range(1, self.attempts + 1):
                if job.cancel.is_set():
                    break
                with self.lock:
                    job.attempt, job.sent = attempt, 0
                    job.error = ""
                try:
                    log = self.backend.upload(name, job.path, lambda sent: self._progress(job, sent), job.cancel)
                    output.append(log)
                    succeeded = True
                    break
                except Exception as exc:
                    output.append(str(exc) + "\n")
                    with self.lock:
                        job.error = str(exc)
                    if attempt == self.attempts:
                        with self.lock:
                            job.state = "failed"
                    else:
                        if job.cancel.wait(self.retry_delay * 2 ** (attempt - 1)):
                            break
        finally:
            with self.lock:
                if succeeded:
                    job.state, job.sent, job.error = "complete", job.size, ""
                elif job.cancel.is_set():
                    job.state, job.error = "cancelled", "No builds still require this upload"
                elif job.state in {"uploading", "cancelling"}:
                    job.state, job.error = "failed", "Upload interrupted"
                job.finished = time.time()
                if succeeded:
                    self.confirmed[name][job.path] = job.finished
                job.output = "".join(output)[-65536:]
                for ticket in job.subscribers:
                    ticket.logs.append(job.output)
                    self._refresh(ticket)
                self.running[name] -= 1
                self.inflight[name].pop(job.path, None)
                self._dispatch(name)
                self._settle()

    def _progress(self, job, sent):
        with self.lock:
            job.sent = max(0, min(int(sent), job.size))

    def cancel(self, ident):
        """Detach one build; never kill a shared transfer needed by another build."""
        with self.lock:
            pub = self.publications[ident]
            for ticket in pub.tickets.values():
                if ticket.state not in TERMINAL:
                    ticket.state = "cancelled"
                    for job in ticket.jobs:
                        if all(t.state in TERMINAL for t in job.subscribers):
                            if job.state == "queued":
                                job.state, job.finished = "cancelled", time.time()
                            elif job.state == "uploading":
                                job.state = "cancelling"
                                job.cancel.set()
            self._settle()

    def cancel_build(self, buildid):
        with self.lock:
            for pub in list(self.publications.values()):
                if pub.metadata.get("build") == buildid and pub.finished is None:
                    self.cancel(pub.id)

    def _expire_confirmed(self, now):
        for cache in self.confirmed.values():
            for path in [path for path, finished in cache.items() if now - finished >= self.success_ttl]:
                del cache[path]

    def _settle(self):
        for pub in list(self.publications.values()):
            if pub.preparing or pub.finished is not None:
                continue
            tickets = pub.tickets.values()
            if all(t.state in TERMINAL for t in tickets) and all(
                j.state in TERMINAL for t in tickets for j in t.jobs
            ):
                pub.finished = time.time()
                if pub.release:
                    # Removing symlinks is local, bounded work; no Nix RPC here.
                    pub.release()
                    pub.release = None
        finished = sorted((p for p in self.publications.values() if p.finished is not None), key=lambda p: p.finished)
        eligible = [p for p in finished if all(t.acknowledged for t in p.tickets.values())
                    or time.time() - p.finished > 3600]
        for pub in eligible[:max(0, len(finished) - self.history)]:
            for ticket in pub.tickets.values():
                for job in ticket.jobs:
                    job.subscribers.discard(ticket)
                    if not job.subscribers and self.jobs[ticket.target].get(job.path) is job:
                        del self.jobs[ticket.target][job.path]
            self.keys.pop(pub.key, None)
            del self.publications[pub.id]

    def poll(self, ident, target, cursor=0):
        with self.lock:
            ticket = self.publications[ident].tickets[target]
            result = ticket.state, "".join(ticket.logs[cursor:]), len(ticket.logs)
            if ticket.state in TERMINAL:
                ticket.acknowledged = True
                self._settle()
            return result

    def snapshot(self, ident=None):
        with self.lock:
            def path_data(job):
                return dict(path=job.path, size=job.size, sent=job.sent, state=job.state,
                            started=job.started, finished=job.finished, attempt=job.attempt,
                            error=job.error, subscribers=len({t.publication for t in job.subscribers
                                                           if t.state != "cancelled"}))

            def ticket_data(ticket):
                data = dict(target=ticket.target, state=ticket.state, error=ticket.error,
                            cached=ticket.cached, upstream=ticket.upstream, paths=len(ticket.jobs),
                            complete=sum(j.state == "complete" for j in ticket.jobs),
                            failed=sum(j.state == "failed" for j in ticket.jobs))
                if ident:
                    data["jobs"] = [path_data(j) for j in ticket.jobs]
                return data

            pubs = [self.publications[ident]] if ident else list(self.publications.values())
            return dict(instance=self.instance, now=time.time(),
                        targets=[dict(name=name, limit=limit, active=self.running[name],
                                      queued=sum(j.state == "queued" for j in self.jobs[name].values()),
                                      jobs=[path_data(j) for j in self.jobs[name].values() if j.state == "uploading"])
                                 for name, limit in self.limits.items()],
                        publications=[dict(id=p.id, metadata=p.metadata, created=p.created, finished=p.finished,
                                           targets=[ticket_data(t) for t in p.tickets.values()])
                                      for p in sorted(pubs, key=lambda p: p.created, reverse=True)])

    def close(self):
        with self.lock:
            self.closed = True
            for pub in list(self.publications.values()):
                self.cancel(pub.id)
        self.planners.shutdown(wait=True)
        self.workers.shutdown(wait=True)
