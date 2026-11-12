"""Report completed automated flake updates, after all children have finished."""

REPOSITORIES = {"anna-oake/nixos-config", "maeve-oake/nixos-config"}
BOT = "github-actions[bot] <github-actions[bot]@users.noreply.github.com>"
FAILURE = 2


def property_value(properties, name):
    return properties.get(name, [None])[0]


async def failed_step(master, build_id, step_name, kind, attribute):
    steps = await master.data.get(("builds", build_id, "steps"))
    for step in steps:
        if step["name"] != step_name or step["results"] != FAILURE:
            continue
        logs = await master.data.get(("steps", step["stepid"], "logs"))
        expected_log = "nix_error" if kind == "evaluation" else "stdio"
        for log in logs:
            if log["name"] == expected_log and log["complete"]:
                return {"type": kind, "attribute": attribute, "log_id": log["logid"]}
        # Do not silently launch an investigation without its diagnostic log.
        raise ValueError(f"Missing completed {expected_log} log for step {step['stepid']}")
    return None


async def collect_failure(master, build):
    # In particular, CANCELLED parents are ignored even if a child failed earlier.
    if not build["complete"] or build["results"] != FAILURE:
        return None
    properties = await master.data.get(("builds", build["buildid"], "properties"))
    prop = lambda name: property_value(properties, name)
    repository = prop("project")
    if (
        repository not in REPOSITORIES
        or prop("buildername") != f"{repository}/nix-eval"
        or prop("event") != "push"
        or prop("branch") != "flake-update"
        or prop("owners") != [BOT]
    ):
        return None

    failures = []
    parent_failure = await failed_step(
        master, build["buildid"], "Evaluate flake", "parent_evaluation", None
    )
    if parent_failure:
        failures.append(parent_failure)

    # Use the DB connector to avoid collection pagination. It is also what
    # buildbot-nix uses when reconstructing the parent's triggered builds.
    children = await master.db.builds.get_triggered_builds(build["buildid"])
    for child in sorted(children, key=lambda child: child.id):
        if child.results != FAILURE:
            continue
        child_properties = await master.data.get(("builds", child.id, "properties"))
        name = property_value(child_properties, "buildername")
        if property_value(child_properties, "dependency.attr") is not None:
            continue
        if name == f"{repository}/nix-failed-eval":
            kind, step_name = "evaluation", "Nix evaluation"
        elif name == f"{repository}/nix-build":
            kind, step_name = "build", "Build flake attr"
        else:
            # Synthetic dependency/cached failures are not actual failed steps.
            continue
        failure = await failed_step(
            master, child.id, step_name, kind,
            property_value(child_properties, "attr"),
        )
        if failure:
            failures.append(failure)

    # A failed aggregate alone is insufficient (e.g. cancelled children).
    if not failures:
        return None
    return {
        "repository": repository,
        "revision": prop("got_revision") or prop("revision"),
        "parent_build_id": build["buildid"],
        "failed_steps": failures,
    }


def make_reporter(url):
    from buildbot.reporters.generators.build import BuildStatusGenerator
    from buildbot.reporters.http import HttpStatusPush
    from buildbot.util.twisted import async_to_deferred

    class FlakeFailureGenerator(BuildStatusGenerator):
        @async_to_deferred
        async def generate(self, master, reporter, key, build):
            payload = await collect_failure(master, build)
            return {"body": payload} if payload else None

    return HttpStatusPush(
        serverUrl=url,
        generators=[FlakeFailureGenerator(
            mode="failing",
            builders=[f"{repo}/nix-eval" for repo in sorted(REPOSITORIES)],
        )],
    )
