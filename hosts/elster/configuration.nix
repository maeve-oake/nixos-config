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
    inputs.decider-efi.nixosModules.default
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

  services.logind.settings.Login = {
    "PowerKeyIgnoreInhibited" = true;
  };

  # boot
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  boot.loader.decider = {
    enable = true;
    chainloadPaths = {
      windows = "ce6a9709-944e-4496-9363-1706dac399ee:/EFI/Microsoft/Boot/bootmgfw.efi";
    };
  };

  # power & sleep
  services.displayManager.gdm.autoSuspend = false;

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
    unstable.modrinth-app
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
