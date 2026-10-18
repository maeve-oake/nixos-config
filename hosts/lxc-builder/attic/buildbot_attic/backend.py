"""Nix/Attic subprocesses, with telemetry kept out of their normal logs."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import threading
import time


class AtticBackend:
    def __init__(self, config):
        self.config = config
        self.attic, self.nix, self.nix_store = (config[k] for k in ("attic", "nix", "nixStore"))
        self.targets = config["targets"]
        state = Path(config["stateDirectory"])
        state.mkdir(parents=True, exist_ok=True, mode=0o700)
        # The queue is process-local. Old runs cannot resume after master restart.
        # Their Buildbot jobs must be retried, which will recheck the caches.
        for old in state.glob("run-*"):
            if old.is_dir() and not old.is_symlink():
                shutil.rmtree(old)
        self.directory = Path(tempfile.mkdtemp(prefix="run-", dir=state))
        self.environments = {}
        for name, target in self.targets.items():
            directory = self.directory / name / "attic"
            directory.mkdir(parents=True, mode=0o700)
            token_file = str(Path(os.environ["CREDENTIALS_DIRECTORY"]) / target["credential"])
            text = '[servers.queue]\nendpoint = ' + json.dumps(target["host"]) + '\ntoken-file = ' + json.dumps(token_file) + '\n'
            path = directory / "config.toml"
            path.write_text(text)
            path.chmod(0o600)
            self.environments[name] = dict(os.environ, XDG_CONFIG_HOME=str(directory.parent))

    def pin(self, ident, roots):
        directory = self.directory / "roots" / ident
        directory.mkdir(parents=True)
        try:
            for i, root in enumerate(roots):
                subprocess.run([self.nix_store, "--add-root", str(directory / str(i)), "--indirect", "--realise", root],
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True, timeout=120)
        except Exception:
            shutil.rmtree(directory)
            raise
        return lambda: shutil.rmtree(directory, ignore_errors=True)

    def closure(self, roots):
        result = subprocess.run([self.nix, "path-info", "--recursive", "--json", *roots],
                                capture_output=True, text=True, check=True, timeout=120)
        data = json.loads(result.stdout)
        if isinstance(data, dict):
            return [dict(path=path, size=info["narSize"]) for path, info in data.items()]
        return [dict(path=info["path"], size=info["narSize"]) for info in data]

    def command(self, name, *args):
        target = self.targets[name]
        return [self.attic, "push", "queue:" + target["cache"],
                *(["--ignore-upstream-cache-filter"] if target["ignoreUpstream"] else []), *args]

    def plan(self, name, paths):
        result = subprocess.run(self.command(name, "--plan-json", "--no-closure", "--stdin"),
                                input="\n".join(paths) + "\n", capture_output=True, text=True,
                                env=self.environments[name], timeout=120)
        if result.returncode:
            raise RuntimeError(result.stderr[-65536:])
        return json.loads(result.stdout)

    def summary(self, name, plan):
        n, cached, upstream = len(plan["paths"]), plan["cached"], plan["upstream"]
        if not n:
            return f"✅ All done! ({cached} already cached, {upstream} in upstream)\n"
        cache = self.targets[name]["cache"]
        return f'⚙️ Pushing {n} paths to "{cache}" on "{name}" ({cached} already cached, {upstream} in upstream)...\n'

    def upload(self, name, path, progress, cancel):
        with tempfile.NamedTemporaryFile(mode="r", dir=self.directory, prefix="progress-") as events:
            env = dict(self.environments[name], ATTIC_PROGRESS_FILE=events.name)
            process = subprocess.Popen(self.command(name, "--no-closure", "-j", "1", path),
                                       env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            chunks = bytearray()

            def read_output():
                while chunk := process.stdout.read(4096):
                    chunks.extend(chunk)
                    del chunks[:-65536]

            reader = threading.Thread(target=read_output, daemon=True)
            reader.start()
            pending = ""
            deadline = time.monotonic() + 6 * 3600
            try:
                while process.poll() is None:
                    if cancel.is_set():
                        raise RuntimeError("Upload cancelled: no builds still require this path")
                    pending += events.read()
                    while "\n" in pending:
                        line, pending = pending.split("\n", 1)
                        event = json.loads(line)
                        progress(event["sent"])
                    if time.monotonic() > deadline:
                        raise TimeoutError("Attic upload exceeded six hours")
                    time.sleep(0.25)
            finally:
                if process.poll() is None:
                    process.terminate()
                    try:
                        process.wait(timeout=5)
                    except subprocess.TimeoutExpired:
                        process.kill()
                process.wait()
                reader.join()
                process.stdout.close()
            output = chunks.decode(errors="replace")
            # One closure summary is emitted per subscriber. Keep Attic's actual
            # success/error lines, without adding per-path subprocess summaries.
            output = "".join(line for line in output.splitlines(keepends=True)
                             if not line.startswith(("⚙️ Pushing ", "✅ All done!")))
            if process.returncode:
                raise RuntimeError(output or f"Attic exited with status {process.returncode}")
            return output
