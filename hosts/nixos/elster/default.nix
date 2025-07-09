{
  inputs,
  config,
  pkgs,
  unstable,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # DE
  gnome = {
    enable = true;
    dockItems.middle = [
      "steam.desktop"
    ];
    powerButtonAction = "interactive";
  };

  # boot
  boot.secureboot.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_6_15;
  networking.interfaces.enp13s0.wakeOnLan.enable = true;

  # power & sleep
  services.xserver.displayManager.gdm.autoSuspend = false;

  # fingerprint & login
  services.fprintd.enable = true;
  security.polkit.enable = true;

  # graphics
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;
  };
  hardware.nvidia = {
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
    easyeda-pro
  ];

  # lnxlink
  age.secrets.lnxlink-env.file = (inputs.self + /secrets/lnxlink-env.age);
  services.lnxlink = {
    enable = true;
    envFile = config.age.secrets.lnxlink-env.path;
    addons = {
      cpu.enable = true;
      memory.enable = true;
      shutdown.enable = true;
      restart.enable = true;
      suspend.enable = true;
      microphone_used.enable = true;
      camera_used.enable = true;
      speaker_used.enable = true;
    };
  };

  # misc
  maeve.samba.enable = true;

  # Do not remove
  system.stateVersion = "24.05";
}
