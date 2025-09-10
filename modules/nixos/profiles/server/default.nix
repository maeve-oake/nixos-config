{
  config,
  lib,
  ...
}:
{
  imports = [
    ./user.nix
  ];

  config = lib.mkIf config.profiles.server.enable {
    lxc.pve.host = lib.mkDefault ("mynah." + config.me.lanDomain);

    programs.nix-index.enable = false;
  };
}
