{
  config,
  pkgs,
  ...
}:
let
  targets = {
    buyan = {
      host = "https://attic-buyan.oa.ke";
      jobs = 12;
      includeUpstream = true;
    };
    kitezh = {
      host = "https://attic-kitezh.oa.ke";
      jobs = 4;
      includeUpstream = false;
    };
  };
  push =
    name: target:
    pkgs.writeShellScript "attic-${name}" ''
      set -eu
      export ATTIC_TOKEN="$(cat "$CREDENTIALS_DIRECTORY/attic-token")"
      exec ${pkgs.nixbot-attic-client}/bin/attic push --endpoint ${target.host} nixos --no-closure --jobs 1 ${
        if target.includeUpstream then "--ignore-upstream-cache-filter" else ""
      } "$@"
    '';
in
{
  services.nixbot.uploaders = builtins.attrValues (
    builtins.mapAttrs (name: target: {
      inherit name;
      inherit (target) jobs;
      command = [ (push name target) ];
      planCommand = [
        "${push name target}"
        "--plan-json"
      ];
    }) targets
  );
  systemd.services.nixbot.serviceConfig.LoadCredential = [
    "attic-token:${config.age.secrets."lxc-builder/attic-auth-token".path}"
  ];
}
