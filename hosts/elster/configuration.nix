{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.default
    inputs.decider-efi.nixosModules.default
    ./hardware-configuration.nix
    ./streaming.nix
    # ./network.nix
  ];

  infra.deploy.auto = true;

  profiles.workstation = {
    enable = true;
    samba.enable = true;
    wifi.enable = true;
    gnome = {
      enable = true;
      dockItems.middle = [
        "ke.oa.miaow.desktop"
        "steam.desktop"
      ];
      shellExtensions = [ pkgs.miaow ];
      powerButtonAction = "suspend";
    };
  };

  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    "PowerKeyIgnoreInhibited" = true;
  };

  # boot
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.decider = {
    enable = true;
    chainloadPaths = {
      windows = "ce6a9709-944e-4496-9363-1706dac399ee:/EFI/Microsoft/Boot/bootmgfw.efi";
    };
  };

  # power & sleep
  services.displayManager.gdm.autoSuspend = false;

  # re-enumerate UMC204HD on resume instead of reset-resume (breaks audio)
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="1397", ATTR{idProduct}=="0508", ATTR{power/persist}="0"
  '';

  # fingerprint & login
  services.fprintd = {
    enable = true;
    cs9711 = true;
  };
  security.polkit.enable = true;

  # graphics
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;
  };
  hardware.nvidia = {
    open = true;
    powerManagement.enable = true;
  };

  # camera
  # hardware.isight.enable = true;

  # packages
  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    # apps
    plex-desktop
    ollama
    darktable
    ffmpeg
    easyeda-pro
    (modrinth-app.overrideAttrs (old: {
      buildCommand = ''
        gappsWrapperArgs+=(
          --set __NV_DISABLE_EXPLICIT_SYNC 1
        )
      ''
      + old.buildCommand;
    }))
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

  monitoring = {
    logs.system.enable = true;
    metrics.enable = true;
    metrics.gpu = "nvidia";
  };

  # Do not remove
  system.stateVersion = "24.05";
}
