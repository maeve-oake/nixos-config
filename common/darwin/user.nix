{
  pkgs,
  config,
  ...
}:
let
  inherit (config.me) username;
in
{
  config.users.knownUsers = [ username ];
  config.users.users.${username} = {
    shell = pkgs.fish;
    uid = 501;
  };
  config.system.primaryUser = username;
  config.security.pam.services.sudo_local.touchIdAuth = true;
}
