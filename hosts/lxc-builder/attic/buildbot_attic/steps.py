"""Wait for shared uploads without blocking the Twisted reactor/thread pool."""

from html import escape
from urllib.parse import urljoin

from buildbot.plugins import steps, util
from buildbot.reporters.utils import getURLForBuild
from twisted.internet import reactor, task

from .runtime import get_queue
from .queue import TERMINAL


async def submit(step, roots=None, attr=None, target=None):
    queue = get_queue()
    outputs = step.getProperty("infra_outputs") or {}
    roots = roots or [p for p in outputs.values() if p]
    if not roots and step.getProperty("out_path"):
        roots = [step.getProperty("out_path")]
    if not roots:
        raise RuntimeError("Cannot queue uploads without built output paths")
    attr = attr or step.getProperty("attr") or "output"
    key = f"{step.build.buildid}:{attr}"
    build = await step.master.data.get(("builds", str(step.build.buildid)))
    url = getURLForBuild(step.master, build["builderid"], build["number"])
    metadata = dict(attr=attr, build=step.build.buildid,
                    hosts=sorted({m["host"] for m in step.getProperty("infra_mappings") or []
                                  if set(m["checks"]) & set(roots)}),
                    repository=step.getProperty("infra_repository") or step.getProperty("project"),
                    revision=step.getProperty("infra_revision") or step.getProperty("got_revision"),
                    buildURL=url)
    # submit() schedules ALL destinations immediately. Each existing upload step
    # then waits for its own destination, preserving ReportUploads' semantics.
    ident = queue.submit(key, roots, metadata)
    links = getattr(step, "_attic_links", set())
    if ident not in links:
        progress_log = step.getLog("uploads") if "uploads" in step.logs else await step.addLog("uploads", type="h")
        await progress_log.addContent(
            '<div data-attic-publication="' + escape(ident, quote=True) + '"'
            + (' data-attic-target="' + escape(target, quote=True) + '"' if target else '')
            + '>Loading uploads…</div>\n'
        )
        await step.addURL("Upload status · " + attr, urljoin(step.master.config.buildbotURL,
                                                          "plugins/attic_uploads/api?publication=" + ident
                                                          + ("&target=" + target if target else "")))
        step._attic_links = links | {ident}
    return ident


async def upload(step, target):
    if step.stopped:
        return util.CANCELLED
    queue = get_queue()
    ident = await submit(step, target=target)
    log = step.getLog("stdio") if "stdio" in step.logs else await step.addLog("stdio")
    cursor = 0
    while True:
        if step.stopped:
            queue.cancel_build(step.build.buildid)
            return util.CANCELLED
        state, text, cursor = queue.poll(ident, target, cursor)
        if text:
            await log.addStderr(text)
        if state in TERMINAL:
            return {"complete": util.SUCCESS, "failed": util.FAILURE, "cancelled": util.CANCELLED}[state]
        await task.deferLater(reactor, 1, lambda: None)


class UploadStep(steps.BuildStep):
    def __init__(self, target, **kwargs):
        super().__init__(**kwargs)
        self.target = target

    async def run(self):
        return await upload(self, self.target)


def upload_step_factory(*, options, **kwargs):
    """Factory registered with buildbot-nix; options belong to this plugin."""
    if set(options) != {"target"} or not isinstance(options["target"], str) or not options["target"]:
        raise ValueError("attic-upload requires exactly one option: a nonempty target string")
    return UploadStep(target=options["target"], **kwargs)
