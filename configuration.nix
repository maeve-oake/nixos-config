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

  # shell
  programs.fish.enable = true;

  # environment variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORMTHEME = "flatpak"; # fix telegram filepicker
  };

  # udev rules
  services.udev.extraRules = ''
    # give vboxusers raw access to Windows 1TB module
    SUBSYSTEM=="block", KERNEL=="sd?", ATTRS{serial}=="071C435B161FE558", MODE="0660", GROUP="vboxusers", SYMLINK+="windows-module-disk"
  '';

  # fingerprint (disabled until i encrypt my disk)
  # services.fprintd.enable = true;

  users.users.maeve = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "input" "vboxusers" ];
    # wheel - sudo  
    # networkmanager - network configuration
    # input - three finger drag
    # vboxusers - virtual box
    shell = pkgs.fish;
  };

  # packages
  programs.steam.enable = true;
  virtualisation.virtualbox.host.enable = true;
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
    ollama
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
