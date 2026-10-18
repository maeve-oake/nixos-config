{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.buildbot-nix.master;
  packages = config.services.buildbot-nix.packages;
  uploadPlugin = packages.python.pkgs.buildPythonPackage {
    pname = "buildbot-attic-uploads";
    version = "0.1.0";
    src = ./.;
    pyproject = true;
    build-system = [ packages.python.pkgs.setuptools ];
    dependencies = [ packages.buildbot ];
    pythonImportsCheck = [
      "buildbot_attic.steps"
      "buildbot_attic.plugin"
    ];
  };
  queueConfig = (pkgs.formats.json { }).generate "attic-upload-queues.json" {
    attic = "${cfg.attic.package}/bin/attic";
    nix = "${pkgs.nix}/bin/nix";
    nixStore = "${pkgs.nix}/bin/nix-store";
    stateDirectory = "${config.services.buildbot-master.home}/attic-uploads";
    targets = lib.mapAttrs (name: server: {
      inherit (server) host;
      cache = server.cacheName;
      jobs = server.uploadJobs;
      ignoreUpstream = server.ignoreUpstreamCache;
      credential = "attic-token-${name}";
    }) cfg.attic.targets;
  };

in
{
  options.services.buildbot-nix.master.attic =
    let
      inherit (lib) types mkOption mkEnableOption;
    in
    {
      package = mkOption {
        type = types.package;
        default = pkgs.attic-client.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ ./events.patch ];
        });
        description = "The attic-client package to use.";
      };

      targets = mkOption {
        default = { };
        type = types.attrsOf (
          types.submodule {
            options = {
              host = mkOption {
                type = types.str;
                description = "Hostname of the Attic server.";
              };
              cacheName = mkOption {
                type = types.str;
                description = "Name of the cache.";
              };
              authTokenFile = mkOption {
                type = types.path;
                description = "Authentication token for the Attic server.";
              };
              ignoreUpstreamCache = mkEnableOption "ignore upstream cache option of attic push.";
              uploadJobs = mkOption {
                type = types.ints.positive;
                default = 5;
                description = "Maximum concurrent transfers to this target across all builds.";
              };
            };
          }
        );
      };
    };

  config = lib.mkIf (cfg.attic.targets != { }) {
    services.buildbot-master.pythonPackages = _: [ uploadPlugin ];
    services.buildbot-master.extraConfig = ''
      c['www'].setdefault('plugins', {})['attic_uploads'] = json.loads(Path('${queueConfig}').read_text())
    '';
    systemd.services.buildbot-master.serviceConfig.LoadCredential = lib.mapAttrsToList (
      name: server: "attic-token-${name}:${toString server.authTokenFile}"
    ) cfg.attic.targets;

    services.buildbot-nix.master.genericPostBuildSteps = lib.mapAttrsToList (name: server: {
      name = "Push to attic - ${name}";
      type = "attic-upload";
      options.target = name;
      warnOnly = true;
    }) cfg.attic.targets;
  };
}
