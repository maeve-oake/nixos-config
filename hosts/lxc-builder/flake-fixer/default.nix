{ ... }:
{
  services.buildbot-master.extraConfig = ''
    import importlib.util
    flake_fixer_spec = importlib.util.spec_from_file_location(
        "flake_failure_reporter", "${./reporter.py}"
    )
    flake_fixer = importlib.util.module_from_spec(flake_fixer_spec)
    flake_fixer_spec.loader.exec_module(flake_fixer)
    c['services'].append(flake_fixer.make_reporter(
        "http://slopster.me.ow:9847/buildbot-failure"
    ))
  '';
}
