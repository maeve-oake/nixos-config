{
  inputs,
  config,
  pkgs,
  unstable,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.default
    ./hardware-configuration.nix
    # ./network.nix
  ];

  # DE
  gnome = {
    enable = true;
    dockItems.middle = [
      "steam.desktop"
    ];
    powerButtonAction = "interactive";
  };

  services.logind.extraConfig = "PowerKeyIgnoreInhibited=yes";

  # boot
  boot.secureboot.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_6_16;

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
  age.secrets.lnxlink-env = { };
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
