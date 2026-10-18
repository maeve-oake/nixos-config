from setuptools import setup

setup(
    name="buildbot-attic-uploads",
    version="0.1.0",
    packages=["buildbot_attic"],
    package_data={"buildbot_attic": ["VERSION", "static/*"]},
    entry_points={
        "buildbot.www": ["attic_uploads = buildbot_attic.plugin:ep"],
        "buildbot_nix.post_build_steps": ["attic-upload = buildbot_attic.steps:upload_step_factory"],
    },
)
