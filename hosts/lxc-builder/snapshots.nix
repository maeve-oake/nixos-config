{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  interpolate = inputs.buildbot-nix.lib.interpolate;
  packages = config.services.buildbot-nix.packages;
  saveSnapshots = pkgs.writeShellScript "save-build-snapshots" ''
    set -euo pipefail
    project="$1"
    revision="$2"
    attr="$3"
    out_path="$4"

    [[ "$project" =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+$ ]]
    [[ "$project" != */. && "$project" != */.. ]]
    [[ "$revision" =~ ^([0-9a-f]{40}|[0-9a-f]{64})$ ]]
    filename=$(${pkgs.jq}/bin/jq -rn --arg attr "$attr" '$attr | @uri')
    directory="/var/lib/nix-diffs/snapshots/$project/$revision"

    umask 022
    ${pkgs.coreutils}/bin/mkdir -p "$directory"
    ${pkgs.dix-snapshots}/bin/dix snapshot "$out_path" --file "$directory/$filename.json"
    ${pkgs.coreutils}/bin/chmod 644 "$directory/$filename.json"
  '';
in
{
  services.buildbot-nix.packages.buildbot-nix =
    (packages.python.pkgs.callPackage "${inputs.buildbot-nix}/packages/buildbot-nix.nix" {
      buildbot-gitea = packages.buildbot-gitea;
    }).overrideAttrs
      (old: {
        patches = (old.patches or [ ]) ++ [ ./buildbot-snapshots.patch ];
      });

  systemd.tmpfiles.rules = [
    "d /var/lib/nix-diffs 0755 root root - -"
    "d /var/lib/nix-diffs/snapshots 0755 buildbot-worker buildbot-worker - -"
  ];

  services.buildbot-nix.master.postBuildSteps = lib.mkBefore [
    {
      name = "Save closure snapshots";
      command = [
        "${saveSnapshots}"
        (interpolate "%(prop:snapshot_project)s")
        (interpolate "%(prop:snapshot_revision)s")
        (interpolate "%(prop:attr)s")
        (interpolate "%(prop:out_path)s")
      ];
      warnOnly = true;
    }
  ];
}
