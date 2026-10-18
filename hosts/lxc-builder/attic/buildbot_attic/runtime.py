from .backend import AtticBackend
from .queue import UploadQueue

_queue = None
_config = None


def configure(config):
    global _queue, _config
    if _queue is not None:
        if config != _config:
            raise ValueError("Restart the Buildbot master to change Attic queue configuration")
        return _queue
    backend = AtticBackend(config)
    _queue = UploadQueue(backend, {name: target["jobs"] for name, target in config["targets"].items()})
    _config = config
    return _queue


def get_queue():
    if _queue is None:
        raise RuntimeError("The attic_uploads Buildbot plugin is not configured")
    return _queue
