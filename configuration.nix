{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./gnome/gnome.nix
    ];

  # allow unfree pkgs
  nixpkgs.config.allowUnfree = true;

  # systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_6_11;
  boot.kernelPatches = [
    {
      name = "WCN785x-bluetooth-fix";
      patch = ./patches/bt-audio.patch;
    }
  ];

  # network
  networking.hostName = "replika";
  networking.networkmanager.enable = true;
  services.avahi.enable = false;
  services.resolved.enable = true;
  networking.firewall.enable = false;

  # localisation
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    keyMap = "uk";
  };
  services.xserver.xkb.layout = "gb";

  #timezone
  services.automatic-timezoned.enable = true;
  services.geoclue2.enableDemoAgent = lib.mkForce true;
  services.geoclue2.geoProviderUrl = "https://beacondb.net/v1/geolocate";

  # power & sleep
  boot.resumeDevice = "/dev/disk/by-label/swap";
  boot.kernelParams = [
    "resume=LABEL=swap"
  ];
  systemd.sleep.extraConfig = ''
    		HibernateDelaySec=30m
    	'';
  services.logind.lidSwitch = "suspend-then-hibernate";

  #   # fucking touchpad scrollspeed (fuck wayland)
  #   services.udev.extraHwdb = ''
  # evdev:name:PIXA3854:00 093A:0274 Touchpad:dmi:*svnFramework:*pnLaptop13(AMDRyzen7040Series)**
  #  EVDEV_ABS_00=::121
  #  EVDEV_ABS_01=::125
  #  EVDEV_ABS_35=::121
  #  EVDEV_ABS_36=::125
  #   '';

  # shell
  programs.fish.enable = true;

  # environment variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORMTHEME = "flatpak"; # fix telegram filepicker
  };

  # fingerprint (disabled until i encrypt my disk)
  # services.fprintd.enable = true;

  users.users.maeve = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    shell = pkgs.fish;
  };

  # packages
  environment.systemPackages = with pkgs; [
    # dev
    git
    gh
    neovim
    nixpkgs-fmt
    dotnet-sdk
    dotnet-runtime
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        ms-dotnettools.csharp
        ms-dotnettools.vscode-dotnet-runtime
        jnoortheen.nix-ide
        ms-vsliveshare.vsliveshare
      ];
    })

    # apps
    microsoft-edge
    telegram-desktop
    discord
    gqrx
    gimp
    plex-desktop
    (callPackage ./pkgs/satdump.nix { })

    # shell
    wget
    p7zip
    lolcat
    zoxide
    fzf
    btop
  ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # Do not remove
  system.stateVersion = "24.05";
}
