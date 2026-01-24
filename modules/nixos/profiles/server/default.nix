{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./user.nix
  ];

  config = lib.mkIf config.profiles.server.enable {
    lxc.pve.host = lib.mkDefault ("mynah." + config.me.lanDomain);

    programs.nix-index.enable = false;

    environment.systemPackages = with pkgs; [
      ghostty.terminfo
    ];

    # mynah host driver
    lxc.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "580.119.02";
      sha256_64bit = "sha256-gCD139PuiK7no4mQ0MPSr+VHUemhcLqerdfqZwE47Nc=";
      openSha256 = "sha256-l3IQDoopOt0n0+Ig+Ee3AOcFCGJXhbH1Q1nh1TEAHTE=";
      useSettings = false;
      usePersistenced = false;
    };
  };
}
