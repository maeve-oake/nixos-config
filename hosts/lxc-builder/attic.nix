{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.buildbot-nix.master;
  interpolate = value: {
    _type = "interpolate";
    inherit value;
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
        default = pkgs.attic-client;
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
                type = types.int;
                default = 5;
                description = "Number of upload jobs to run in parallel.";
              };
            };
          }
        );
      };
    };

  config = lib.mkIf (cfg.attic.targets != { }) {
    systemd.services.buildbot-worker.path = [
      (pkgs.writeShellScriptBin "attic-login-push" ''
        set -eu -o pipefail
        ${pkgs.attic-client}/bin/attic login "$ATTIC_NAME" "$ATTIC_HOST" "$ATTIC_TOKEN"

        extra=()
        [ "''${ATTIC_IGNORE_UPSTREAM:-0}" = "1" ] && extra+=(--ignore-upstream-cache-filter)
        ${pkgs.attic-client}/bin/attic push "$ATTIC_NAME:$ATTIC_CACHE" -j "$ATTIC_JOBS" ''${extra[@]} "$@"
      '')
    ];

    systemd.services.buildbot-master.serviceConfig.LoadCredential = lib.mapAttrsToList (
      name: server: "attic-token-${name}:${toString server.authTokenFile}"
    ) cfg.attic.targets;

    services.buildbot-nix.master.postBuildSteps = lib.mapAttrsToList (name: server: {
      name = "Push to attic - ${name}";
      environment = {
        ATTIC_NAME = name;
        ATTIC_HOST = server.host;
        ATTIC_CACHE = server.cacheName;
        ATTIC_JOBS = toString server.uploadJobs;
        ATTIC_IGNORE_UPSTREAM = if server.ignoreUpstreamCache then "1" else "0";
        ATTIC_TOKEN = interpolate "%(secret:attic-token-${name})s";
      };
      command = [
        "attic-login-push"
        (interpolate "result-%(prop:attr)s")
      ];
      warnOnly = true;
    }) cfg.attic.targets;
  };
}
