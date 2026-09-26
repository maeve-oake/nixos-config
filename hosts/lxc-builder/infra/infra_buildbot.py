"""Local Buildbot → infra inbox writer. No HTTP client or background service."""

from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile
from datetime import datetime, timezone

PRODUCER = "dix-69f91d6-schema1"


def encoded(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":")).encode()


def atomic_file(path: Path, data: bytes, mode=0o640):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(prefix=".writing-", dir=path.parent)
    try:
        with os.fdopen(fd, "wb") as f:
            os.fchmod(f.fileno(), mode)
            f.write(data)
            f.flush()
            os.fsync(f.fileno())
        os.replace(tmp, path)
        fd = os.open(path.parent, os.O_RDONLY)
        try:
            os.fsync(fd)
        finally:
            os.close(fd)
    finally:
        Path(tmp).unlink(missing_ok=True)


class Reporter:
    def __init__(self):
        self.inbox = Path("/var/lib/infra-hub/inbox")

    def event(self, repository, revision, kind, status, **fields):
        event = dict(
            repository=repository,
            revision=revision,
            kind=kind,
            status=status,
            observed_at=fields.pop(
                "observed_at", datetime.now(timezone.utc).isoformat()
            ),
            **fields,
        )
        event["id"] = hashlib.sha256(encoded(event)).hexdigest()
        atomic_file(
            self.inbox / (event["id"] + ".event.json"), encoded(event), mode=0o660
        )

    def evaluation(
        self, repo, rev, outputs, mappings, errors, log_url
    ):
        self.event(
            repo,
            rev,
            "evaluation",
            "failed" if errors else "success",
            outputs=outputs,
            mappings=mappings,
            errors=errors,
            log_url=log_url,
            inventory_complete=not errors,
            detail="; ".join(f"{k}: {v}" for k, v in errors.items())[:32768],
        )

    def build(self, repo, rev, paths, mappings, success, log_url, detail=""):
        for path in sorted(set(paths)):
            self.event(
                repo,
                rev,
                "build",
                "success" if success else "failed",
                artifact=path,
                detail=detail[-32768:],
                log_url=log_url,
            )
        if not success:
            return
        related = self.related(mappings, paths)
        roots = {m[k] for m in related for k in ("system", "activation")}
        for path in sorted(roots - set(paths)):
            self.event(repo, rev, "build", "success", artifact=path, log_url=log_url)
        errors = []
        for path in sorted({m["system"] for m in related}):
            try:
                self.snapshot(path)
            except Exception as exc:
                errors.append(str(exc))
        if errors:
            raise RuntimeError("\n".join(errors))

    @staticmethod
    def related(mappings, paths):
        return [m for m in mappings if set(m["checks"]) & set(paths)]

    def ready(self, repo, rev, paths, mappings, success, log_url, detail=""):
        roots = {
            m[k]
            for m in self.related(mappings, paths)
            for k in ("system", "activation")
        }
        for root in sorted(roots):
            self.event(
                repo, rev, "ready", "success" if success else "failed",
                artifact=root, log_url=log_url, detail=detail[-32768:],
            )

    def command(self, args, **kwargs):
        result = subprocess.run(
            args, capture_output=True, text=True, timeout=3600, **kwargs
        )
        if result.returncode:
            # Keep command arguments out of error messages.
            raise RuntimeError(
                f"{args[0]} failed (exit {result.returncode}): {result.stderr[-8192:]}"
            )
        return result.stdout

    def snapshot(self, path):
        # Temporary work and the finished submission live only in the inbox.
        # The hub owns permanent snapshot storage and content deduplication.
        self.inbox.mkdir(parents=True, exist_ok=True)
        key = hashlib.sha256((PRODUCER + "\0" + path).encode()).hexdigest()
        fd, tmp = tempfile.mkstemp(prefix=".snapshot-", dir=self.inbox)
        os.close(fd)
        try:
            self.command(["dix", "snapshot", path, "--file", tmp])
            data = Path(tmp).read_bytes()
            value = json.loads(data)
            if value.get("schema_version") != 1 or value.get("root") != path:
                raise ValueError("unexpected dix snapshot schema/root")
            atomic_file(self.inbox / (key + ".snapshot.json"), data, mode=0o660)
        finally:
            Path(tmp).unlink(missing_ok=True)
