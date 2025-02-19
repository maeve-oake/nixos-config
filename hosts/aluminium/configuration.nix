{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../gnome/gnome.nix
    ../../common/secureboot.nix
  ];

  # flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # boot
  boot.loader.timeout = 0;
  boot.kernelPackages = pkgs.linuxPackages_6_13;

  # network
  networking.hostName = "aluminium";

  # power & sleep
  swapDevices = [{ device = "/swapfile"; size = 16 * 1024; }];
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
