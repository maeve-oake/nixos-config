{ config, lib, pkgs, ... }:
let
  sources = import ./nix/sources.nix;
  lanzaboote = import sources.lanzaboote;
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./gnome/gnome.nix
      lanzaboote.nixosModules.lanzaboote
    ];

  # allow unfree pkgs
  nixpkgs.config.allowUnfree = true;

  # boot
  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_6_13;
  boot.bootspec.enable = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  # network
  networking.hostName = "replika";
  networking.networkmanager.enable = true;
  services.avahi.enable = false;
  services.resolved.enable = true;
  networking.firewall.enable = false;
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "client";

  # localisation
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    keyMap = "uk";
  };
  services.xserver.xkb.layout = "gb";

  # timezone
  services.automatic-timezoned.enable = true;
  services.geoclue2.enableDemoAgent = lib.mkForce true;
  services.geoclue2.geoProviderUrl = "https://beacondb.net/v1/geolocate";

  # power & sleep
  swapDevices = [{ device = "/swapfile"; size = 64 * 1024; }];
  boot.kernelParams = [
    "amd_pstate=guided"
  ];
  systemd.sleep.extraConfig = ''
    		HibernateDelaySec=30m
    	'';
  services.logind.lidSwitch = "suspend-then-hibernate";
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;
  boot.kernelModules = [ "amd_pstate" "amd_pstate_ut" ];

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

  # fingerprint & login
  services.fprintd.enable = true;
  security.polkit.enable = true;

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
  services.fwupd.enable = true;
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
    bitwarden-desktop
    (callPackage ./pkgs/satdump.nix { })

    # shell
    wget
    p7zip
    lolcat
    zoxide
    fzf
    btop

    # niv
    niv
  ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # Do not remove
  system.stateVersion = "24.05";
}
