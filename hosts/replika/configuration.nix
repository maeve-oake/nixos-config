{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../gnome/gnome.nix
  ];

  # flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # boot
  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_6_13;
  boot.bootspec.enable = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  networking.hostName = "replika";

  # power & sleep
  swapDevices = [{ device = "/swapfile"; size = 64 * 1024; }];
  boot.kernelParams = [
    "amd_pstate=guided"
  ];
  systemd.sleep.extraConfig = ''
    		HibernateDelaySec=30m
    	'';
  services.logind.lidSwitch = "suspend-then-hibernate";
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;
  boot.kernelModules = [ "amd_pstate" "amd_pstate_ut" ];

  # udev rules
  services.udev.extraRules = ''
    # give vboxusers raw access to Windows 1TB module
    SUBSYSTEM=="block", KERNEL=="sd?", ATTRS{serial}=="071C435B161FE558", MODE="0660", GROUP="vboxusers", SYMLINK+="windows-module-disk"
  '';

  # fingerprint & login
  services.fprintd.enable = true;
  security.polkit.enable = true;

  # packages
  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    # apps
    gqrx
    plex-desktop
    ollama
    (callPackage ../../pkgs/satdump.nix { })
  ];

  # Do not remove
  system.stateVersion = "24.05";
}
