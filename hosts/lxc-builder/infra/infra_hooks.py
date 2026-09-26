"""Adapter for buildbot-nix defca547351c64e7a71c10b0a563450d199fde90.

Called at evaluation, actual build completion, and skipped/synthetic results.
Snapshot generation and local file writes run off the Twisted reactor thread.
"""

from __future__ import annotations

import functools

from buildbot.plugins import util, steps
from buildbot.process import buildstep
from buildbot.reporters.utils import getURLForBuild
from twisted.internet import threads

from .infra_buildbot import Reporter


async def warning(step, exc):
    step.infra_warning_count = getattr(step, "infra_warning_count", 0) + 1
    await step.addCompleteLog(
        f"infra-reporting-error-{step.infra_warning_count}", str(exc)
    )


async def context(step, repo=None):
    props = step.getProperties()
    repo = repo or props.getProperty("infra_repository")
    rev = props.getProperty("infra_revision") or props.getProperty("got_revision")
    build = await step.master.data.get(("builds", str(step.build.buildid)))
    url = getURLForBuild(step.master, build["builderid"], build["number"])
    return repo, rev, url


async def evaluation(step, jobs, branch_config):
    try:
        repo, rev, url = await context(step, step.project.name)
        outputs, errors = {}, {}
        supported = step.nix_eval_config.supported_systems
        for job in jobs:
            name = branch_config.attribute + "." + job.attr
            if hasattr(job, "error"):
                errors[name] = job.error
            elif job.system in supported:
                for output, path in job.outputs.items():
                    attr = name if output == "out" else name + "^" + output
                    if path:
                        outputs[attr] = path
                    else:
                        errors[attr] = "Output path is not statically known"
        mappings = []
        for job in jobs:
            host = (getattr(job, "meta", None) or {}).get("infra")
            if not host:
                continue
            if job.system not in supported:
                errors["Host " + host["name"]] = (
                    "Host system is not supported by these Buildbot workers"
                )
                continue
            mappings.append(
                dict(
                    host=repo + "/" + host["name"],
                    platform=host["platform"],
                    automatic=host["automatic"],
                    system=host["system"],
                    activation=host["activation"],
                    checks=[p for p in job.outputs.values() if p],
                )
            )
        step.setProperty("infra_enabled", bool(mappings), "infra")
        step.setProperty("infra_mappings", mappings, "infra")
        await threads.deferToThread(
            Reporter().evaluation,
            repo,
            rev,
            outputs,
            mappings,
            errors,
            url,
        )
        step.setProperty("infra_evaluation_reported", True, "infra")
    except Exception as exc:
        await warning(step, exc)


def evaluation_failures(run):
    @functools.wraps(run)
    async def wrapped(step):
        step.setProperty("infra_evaluation_reported", False, "infra")
        try:
            result = await run(step)
        except Exception:
            await failed_evaluation(step)
            raise
        if result not in (util.SUCCESS, util.WARNINGS):
            await failed_evaluation(step)
        return result

    return wrapped


async def failed_evaluation(step):
    if step.getProperty("infra_evaluation_reported"):
        return
    try:
        repo, rev, url = await context(step, step.project.name)
        await threads.deferToThread(
            Reporter().evaluation,
            repo,
            rev,
            {},
            [],
            {"Evaluation": "Evaluation failed; see Buildbot log"},
            url,
        )
    except Exception as exc:
        await warning(step, exc)


async def built(step, result, detail=""):
    try:
        repo, rev, url = await context(step)
        if not step.getProperty("infra_enabled"):
            return
        step.setProperty("infra_build_succeeded", result == util.SUCCESS, "infra")
        paths = [p for p in (step.getProperty("infra_outputs") or {}).values() if p]
        if not repo or not rev or not paths:
            raise RuntimeError("Missing infra build context")
        await threads.deferToThread(
            Reporter().build,
            repo,
            rev,
            paths,
            step.getProperty("infra_mappings") or [],
            result == util.SUCCESS,
            url,
            detail
            or ("Nix build failed; see Buildbot log" if result != util.SUCCESS else ""),
        )
    except Exception as exc:
        await warning(step, exc)


async def skipped(step, jobs):
    for job in jobs:
        step.infra_done = getattr(step, "infra_done", set()) | {job.attr}
        try:
            repo, rev, url = await context(step, step.project.name)
            if not step.getProperty("infra_enabled"):
                return
            step.infra_skipped = getattr(step, "infra_skipped", []) + [job]
            await threads.deferToThread(
                Reporter().build,
                repo,
                rev,
                [p for p in job.outputs.values() if p],
                step.getProperty("infra_mappings") or [],
                True,
                url,
            )
        except Exception as exc:
            await warning(step, exc)


async def synthetic_failure(step, job, brids, result):
    """Cached/dependency/cancelled builds never run NixBuildCommand."""
    step.infra_done = getattr(step, "infra_done", set()) | {job.attr}
    if (
        result in (util.SUCCESS, util.WARNINGS)
        or not hasattr(job, "outputs")
    ):
        return
    try:
        repo, rev, url = await context(step, step.project.name)
        if not step.getProperty("infra_enabled"):
            return
        for brid in brids.values():
            builds = await step.master.db.builds.getBuilds(buildrequestid=brid)
            for build in builds:
                steps = await step.master.data.get(("builds", str(build.id), "steps"))
                if any(
                    s["name"] == "Build flake attr" and s.get("complete") for s in steps
                ):
                    return  # actual Nix result already reported, separately from post-build warnings
                url = getURLForBuild(step.master, build.builderid, build.number)
        await threads.deferToThread(
            Reporter().build,
            repo,
            rev,
            [p for p in job.outputs.values() if p],
            step.getProperty("infra_mappings") or [],
            False,
            url,
            "Build "
            + util.Results[result]
            + " (cached failure, dependency failure, or cancellation); see Buildbot log",
        )
    except Exception as exc:
        await warning(step, exc)


async def cancelled(step):
    try:
        repo, rev, url = await context(step, step.project.name)
        if not step.getProperty("infra_enabled"):
            return
        for job in step.jobs_config.successful_jobs:
            if job.attr not in getattr(step, "infra_done", set()):
                await threads.deferToThread(
                    Reporter().build,
                    repo,
                    rev,
                    [p for p in job.outputs.values() if p],
                    step.getProperty("infra_mappings") or [],
                    False,
                    url,
                    "Parent build interrupted; attribute did not finish",
                )
    except Exception as exc:
        await warning(step, exc)


class ReportUploads(steps.BuildStep):
    """Read the existing Attic step results from Buildbot, then report readiness."""

    def __init__(self, upload_steps, **kwargs):
        super().__init__(**kwargs)
        self.upload_steps = upload_steps

    async def run(self):
        if (
            not self.getProperty("infra_enabled")
            or not self.getProperty("infra_build_succeeded")
            or not self.upload_steps
        ):
            return util.SKIPPED
        try:
            recorded = await self.master.data.get(
                ("builds", str(self.build.buildid), "steps")
            )
            results = {s["name"]: s for s in recorded}
            failed = [
                name for name in self.upload_steps
                if not results.get(name, {}).get("complete")
                or results[name].get("results") != util.SUCCESS
            ]
            repo, rev, url = await context(self)
            await threads.deferToThread(
                Reporter().ready, repo, rev,
                list((self.getProperty("infra_outputs") or {}).values()),
                self.getProperty("infra_mappings") or [],
                not failed, url,
                "Attic upload failed or did not complete: " + ", ".join(failed)
                if failed else "",
            )
            return util.SUCCESS
        except Exception as exc:
            await warning(self, exc)
            return util.WARNINGS


class FinishSkippedBuilds(buildstep.ShellMixin, steps.BuildStep):
    """Run existing upload steps for outputs that needed no Nix build."""

    def __init__(self, repo, revision, jobs, uploads, **kwargs):
        kwargs = self.setupShellMixin(kwargs)
        super().__init__(**kwargs)
        self.repo, self.revision, self.jobs, self.uploads = (
            repo,
            revision,
            jobs,
            uploads,
        )

    async def run(self):
        from .models import Interpolate

        failed = False
        for job in self.jobs:
            for key, value in {
                "infra_repository": self.repo,
                "infra_revision": self.revision,
                "infra_outputs": job.outputs,
                "out_path": job.outputs.get("out"),
                "attr": job.attr,
                "cacheStatus": "local",
            }.items():
                self.setProperty(key, value, "infra")
            _, _, url = await context(self)
            path = job.outputs.get("out")
            if not path:
                continue
            link = "result-" + job.attr
            cmd = await self.makeRemoteShellCommand(
                command=["ln", "-sfn", path, link], logEnviron=False
            )
            await self.runCommand(cmd)
            if cmd.didFail():
                failed = True
                continue
            try:
                upload_failures = []
                uploads = [u for u in self.uploads if "ATTIC_HOST" in u.environment]
                for upload in uploads:
                    command = await self.render(
                        [Interpolate.to_buildbot(x) for x in upload.command]
                    )
                    env = await self.render(
                        {
                            k: Interpolate.to_buildbot(v)
                            for k, v in upload.environment.items()
                        }
                    )
                    cmd = await self.makeRemoteShellCommand(
                        command=command,
                        env=env,
                        logEnviron=False,
                    )
                    await self.runCommand(cmd)
                    if cmd.didFail():
                        upload_failures.append(upload.name)
                if uploads:
                    await threads.deferToThread(
                        Reporter().ready, self.repo, self.revision,
                        list(job.outputs.values()),
                        self.getProperty("infra_mappings") or [],
                        not upload_failures, url,
                        "Attic upload failed: " + ", ".join(upload_failures)
                        if upload_failures else "",
                    )
                failed = failed or bool(upload_failures)
            except Exception as exc:
                failed = True
                await warning(self, exc)
            finally:
                cmd = await self.makeRemoteShellCommand(
                    command=["rm", "-f", link], logEnviron=False
                )
                await self.runCommand(cmd)
        return util.WARNINGS if failed else util.SUCCESS


def finish_skipped(step):
    jobs = getattr(step, "infra_skipped", [])
    if jobs:
        step.build.addStepsAfterCurrentStep(
            [
                FinishSkippedBuilds(
                    repo=step.project.name,
                    revision=step.getProperty("got_revision"),
                    jobs=jobs,
                    uploads=step.infra_uploads,
                    name="Upload already-local outputs",
                    warnOnFailure=True,
                    flunkOnFailure=False,
                )
            ]
        )
