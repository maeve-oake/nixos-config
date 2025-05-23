{ pkgs, config, ... }:
{
  users.knownUsers = [ "maeve" ];
  users.users.maeve = {
    shell = pkgs.fish;
    uid = 501;
  };
  config.system.primaryUser = "maeve";

  security.pam.enableSudoTouchIdAuth = true;
}
