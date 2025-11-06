{
  config,
  pkgs,
  ...
}:
let
  mkAtticService = name: extraArgs: {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    environment.HOME = "/var/lib/attic-${name}-watch-store";
    serviceConfig = {
      DynamicUser = true;
      MemoryMax = "15%";
      LoadCredential = "attic-${name}-auth-token:${
        config.age.secrets."lxc-builder/attic-auth-token".path
      }";
      StateDirectory = "attic-${name}-watch-store";
      Restart = "always";
    };
    path = [ pkgs.attic-client ];
    script = ''
      set -eux -o pipefail
      ATTIC_TOKEN=$(< $CREDENTIALS_DIRECTORY/attic-${name}-auth-token)
      attic login attic-${name} https://attic-${name}.oa.ke $ATTIC_TOKEN
      exec attic watch-store attic-${name}:nixos ${extraArgs}
    '';
  };
in
{
  age.secrets."lxc-builder/attic-auth-token" = { };

  systemd.services.attic-buyan-watch-store = mkAtticService "buyan" "--ignore-upstream-cache-filter";
  systemd.services.attic-kitezh-watch-store = mkAtticService "kitezh" "";
}
