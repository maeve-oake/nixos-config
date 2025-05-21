{
  inputs,
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    # (inputs.self + /common/x86_64-linux/i3)
    (inputs.self + /common/x86_64-linux/gnome)
    # (inputs.self + /common/x86_64-linux/secureboot.nix)
  ];

  # boot
  boot.loader.systemd-boot.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_6_14;

  # power & sleep
  swapDevices = [
    {
      device = "/swapfile";
      size = 32 * 1024;
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
    satdump
    gqrx
  ];

  # Do not remove
  system.stateVersion = "24.11";
}
