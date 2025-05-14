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
    # (inputs.self + /common/x86_64-linux/samba.nix)
  ];

  # boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;
  boot.kernelPackages = pkgs.linuxPackages_6_14;

  # power & sleep
  swapDevices = [
    {
      device = "/swapfile";
      size = 32 * 1024;
    }
  ];

  # fingerprint & login
  services.fprintd.enable = true;
  security.polkit.enable = true;

  # # graphics
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.graphics = {
  #   enable = true;
  # };
  # hardware.nvidia = {
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  #   modesetting.enable = true;
  #   powerManagement.enable = false;
  #   powerManagement.finegrained = false;
  #   open = false;
  #   nvidiaSettings = true;
  # };

  # packages
  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    # apps
    plex-desktop
    ollama
    darktable
  ];

  # Do not remove
  system.stateVersion = "24.05";
}
