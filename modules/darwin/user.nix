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

  programs.fish.enable = true; # temporary - server profile on nix-things doesn't import fish.nix here

  security.pam.services.sudo_local.touchIdAuth = true;
}
