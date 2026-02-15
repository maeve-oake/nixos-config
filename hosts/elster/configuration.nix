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

  services.logind.settings.Login = {
    "PowerKeyIgnoreInhibited" = true;
  };

  # boot
  boot.kernelPackages = pkgs.linuxPackages_6_19;

  # power & sleep
  services.displayManager.gdm.autoSuspend = false;

  # fingerprint & login
  services.fprintd.enable = true;
  security.polkit.enable = true;

  # graphics
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    # TODO: might wanna remove when https://github.com/NixOS/nixpkgs/issues/489947 is fixed
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "580.126.09";
      sha256_64bit = "sha256-TKxT5I+K3/Zh1HyHiO0kBZokjJ/YCYzq/QiKSYmG7CY=";
      sha256_aarch64 = "sha256-c5PEKxEv1vCkmOHSozEnuCG+WLdXDcn41ViaUWiNpK0=";
      openSha256 = "sha256-ychsaurbQ2KNFr/SAprKI2tlvAigoKoFU1H7+SaxSrY=";
      settingsSha256 = "sha256-4SfCWp3swUp+x+4cuIZ7SA5H7/NoizqgPJ6S9fm90fA=";
      persistencedSha256 = "sha256-J1UwS0o/fxz45gIbH9uaKxARW+x4uOU1scvAO4rHU5Y=";
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
