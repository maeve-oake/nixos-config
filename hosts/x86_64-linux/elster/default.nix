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
    (inputs.self + /common/x86_64-linux/secureboot.nix)
    # (inputs.self + /common/x86_64-linux/samba.nix)
  ];

  # boot
  boot.kernelPackages = unstable.linuxPackages_6_14;
  networking.interfaces.enp13s0.wakeOnLan.enable = true;

  # power & sleep
  services.xserver.displayManager.gdm.autoSuspend = false;
  swapDevices = [
    {
      device = "/swapfile";
      size = 32 * 1024;
    }
  ];

  # fingerprint & login
  services.fprintd.enable = true;
  security.polkit.enable = true;

  # graphics
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;
  };
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
  };

  # camera
  hardware.isight.enable = true;

  # packages
  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    # apps
    plex-desktop
    ollama
    darktable
    ffmpeg
  ];

  # Do not remove
  system.stateVersion = "24.05";
}
