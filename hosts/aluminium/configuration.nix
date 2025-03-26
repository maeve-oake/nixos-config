{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/x86_64-linux/gnome
    ../../common/x86_64-linux/secureboot.nix
  ];

  # boot
  boot.loader.timeout = 0;
  boot.kernelPackages = pkgs.linuxPackages_6_13;

  # network
  networking.hostName = "aluminium";

  # power & sleep
  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024;
    }
  ];
  systemd.sleep.extraConfig = ''
    		HibernateDelaySec=30m
    	'';
  services.logind.lidSwitch = "suspend-then-hibernate";

  # fingerprint & login
  services.fprintd.enable = true;
  security.polkit.enable = true;

  # packages
  environment.systemPackages = with pkgs; [
    # apps
    teams-for-linux
  ];

  # Do not remove
  system.stateVersion = "24.05";
}
