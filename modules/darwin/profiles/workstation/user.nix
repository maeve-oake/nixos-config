{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (config.me) username;
in
{
  config = lib.mkIf config.profiles.workstation.enable {
    users.knownUsers = [ username ];
    users.users.${username} = {
      shell = pkgs.fish;
      uid = 501;
    };
    system.primaryUser = username;
    security.pam.services.sudo_local.touchIdAuth = true;
  };
}
