{
  pkgs,
  ...
}:
{
  config.users.knownUsers = [ "maeve" ];
  config.users.users.maeve = {
    shell = pkgs.fish;
    uid = 501;
  };
  config.system.primaryUser = "maeve";
  config.security.pam.services.sudo_local.touchIdAuth = true;
}
