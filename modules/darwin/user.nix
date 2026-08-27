{
  pkgs,
  config,
  ...
}:
{
    users.knownUsers = [ config.me.username ];
    users.users.${config.me.username} = {
      uid = 501;
      home = "/Users/${config.me.username}";
      openssh.authorizedKeys.keys = [
        config.me.sshKey
      ];
      shell = pkgs.fish;
    };
    system.primaryUser = config.me.username;
    
    security.pam.services.sudo_local.touchIdAuth = true;
}
