import json

from buildbot.www.plugin import Application
from twisted.internet import reactor, threads
from twisted.web.resource import Resource

from .runtime import configure, get_queue


class Snapshot(Resource):
    isLeaf = True

    def render_GET(self, request):
        request.setHeader(b"Content-Type", b"application/json; charset=utf-8")
        request.setHeader(b"Cache-Control", b"no-store")
        try:
            ident = request.args.get(b"publication", [b""])[0].decode("ascii") or None
            return json.dumps(get_queue().snapshot(ident)).encode()
        except (KeyError, UnicodeError):
            request.setResponseCode(404)
            return b'{"error":"Publication no longer in memory; it may predate a master restart."}'


class UploadApplication(Application):
    def __init__(self):
        super().__init__("buildbot_attic", "Attic upload status in build steps", ui=True)
        self.resource.putChild(b"api", Snapshot())
        self.shutdown_registered = False
        self.consumer_started = False

    def setConfiguration(self, config):
        super().setConfiguration(config)
        queue = configure(config)
        if not self.consumer_started:
            reactor.callWhenRunning(self._subscribe)
            self.consumer_started = True
        if not self.shutdown_registered:
            reactor.addSystemEventTrigger("before", "shutdown", lambda: threads.deferToThread(queue.close))
            self.shutdown_registered = True

    def _subscribe(self):
        # Covers cancellation between steps and pre-submitted already-local
        # hosts whose individual wait has not started yet.
        self.master.mq.startConsuming(self._build_finished, ("builds", None, "finished"))

    def _build_finished(self, key, build):
        get_queue().cancel_build(build["buildid"])


ep = UploadApplication()
