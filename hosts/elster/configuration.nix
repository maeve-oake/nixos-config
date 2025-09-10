{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.default
    ./hardware-configuration.nix
    # ./network.nix
  ];

  profiles.workstation = {
    enable = true;
    samba.enable = true;
    wifi.enable = true;
  };

  # DE
  profiles.workstation.gnome = {
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

    # TODO: figure this out once they fix it
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "580.82.07";
      sha256_64bit = "sha256-Bh5I4R/lUiMglYEdCxzqm3GLolQNYFB0/yJ/zgYoeYw=";
      openSha256 = "sha256-8/7ZrcwBMgrBtxebYtCcH5A51u3lAxXTCY00LElZz08=";
      settingsSha256 = "sha256-lx1WZHsW7eKFXvi03dAML6BoC5glEn63Tuiz3T867nY=";
      usePersistenced = false;
    };
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

  # Do not remove
  system.stateVersion = "24.05";
}
