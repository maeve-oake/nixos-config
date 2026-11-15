import hashlib
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path
from urllib.parse import quote


def atomic(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(prefix=".writing-", dir=path.parent)
    try:
        with os.fdopen(fd, "wb") as stream:
            os.fchmod(stream.fileno(), 0o660)
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(tmp, path)
        fd = os.open(path.parent, os.O_RDONLY)
        try:
            os.fsync(fd)
        finally:
            os.close(fd)
    finally:
        Path(tmp).unlink(missing_ok=True)


def encoded(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":")).encode()


def host(job):
    return ((job.get("extra_value") or {}).get("meta") or {}).get("infra")


def mappings(context):
    result = []
    for job in context.get("attributes", []):
        meta = host(job)
        if meta:
            result.append(
                dict(
                    host=payload["repository"] + "/" + meta["name"],
                    platform=meta["platform"],
                    automatic=meta["automatic"],
                    system=meta["system"],
                    activation=meta["activation"],
                    checks=[p for p in job["outputs"].values() if p],
                )
            )
    return result


def event(kind, status, **fields):
    value = dict(
        repository=payload["repository"],
        revision=payload["revision"],
        kind=kind,
        status=status,
        log_url=fields.pop("log_url", payload["url"]),
        observed_at=payload.get("observed_at"),
        **fields,
    )
    value["id"] = hashlib.sha256(
        encoded([payload["build_id"], payload["generation"], payload["kind"], value])
    ).hexdigest()
    atomic(inbox / (value["id"] + ".event.json"), encoded(value))


def snapshot(root):
    if not isinstance(root, str) or not re.fullmatch(
        r"/nix/store/[0-9abcdfghijklmnpqrsvwxyz]{32}-[^/\s]+", root
    ):
        raise ValueError("snapshot root must be a Nix store root")
    result = subprocess.run(
        ["dix", "snapshot", root], capture_output=True, check=True, timeout=3600
    )
    data = json.loads(result.stdout)
    if data.get("version") != 1 or data.get("path") != root:
        raise ValueError("unexpected dix snapshot root/version")
    name = hashlib.sha256(("dix-3-v1\0" + root).encode()).hexdigest() + ".snapshot.json"
    atomic(inbox / name, result.stdout)
    print("Submitted dix snapshot for " + root, flush=True)


payload = json.loads(Path(os.environ["NIXBOT_CONTEXT_FILE"]).read_text())
inbox = Path(os.environ.get("INFRA_INBOX", "/var/lib/infra-hub/inbox"))
if payload["kind"] == "evaluation_finished":
    errors = {item["attr"]: item["error"][:2048] for item in payload["errors"]}
    if payload.get("error"):
        errors["Evaluation"] = payload["error"][:2048]
    outputs = {}
    for job in payload["attributes"]:
        for key, path in job.get("outputs", {}).items():
            if path:
                outputs[job["attr"] + ("^" + key if key != "out" else "")] = path
    event(
        "evaluation",
        "failed" if errors else "success",
        outputs=outputs,
        mappings=mappings(payload),
        errors=errors,
        inventory_complete=payload["inventory_complete"],
        log_url=payload["url"] + "/eval",
    )
    print("Submitted evaluation inventory", flush=True)
else:
    job = payload["attribute"]
    log_url = payload["url"] + "/logs/" + quote(job["attr"], safe="")
    paths = {p for p in job.get("outputs", {}).values() if p}
    if (job.get("extra_value") or {}).get("buildDependenciesOnly") or payload[
        "outcome"
    ] == "cancelled":
        paths = set()
    related = mappings({"attributes": [job]}) if paths else []
    roots = {m[k] for m in related for k in ("system", "activation")}
    success = payload["outcome"] in ("success", "succeeded", "skipped_local")
    compiled = payload.get("compilation_outcome", payload["outcome"]) in (
        "success",
        "succeeded",
        "skipped_local",
    )
    if success:
        for root in sorted({m["system"] for m in related}):
            snapshot(root)
    for path in sorted(paths | roots):
        event("build", "success" if compiled else "failed", artifact=path, log_url=log_url)
    if payload["outcome"] != "cancelled":
        for path in sorted(roots):
            event("ready", "success" if success else "failed", artifact=path, log_url=log_url)
    print(
        "Submitted attribute " + payload["outcome"] + " for " + job["attr"], flush=True
    )
