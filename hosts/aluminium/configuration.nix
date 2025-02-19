{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../gnome/gnome.nix
  ];

  # flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking.hostName = "aluminium";
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
  swapDevices = [{ device = "/swapfile"; size = 16 * 1024; }];
  systemd.sleep.extraConfig = ''
    		HibernateDelaySec=30m
    	'';
  services.logind.lidSwitch = "suspend-then-hibernate";

  # environment variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORMTHEME = "flatpak"; # fix telegram filepicker
  };

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
  virtualisation.virtualbox.host.enable = true;
  services.fwupd.enable = true;
  environment.systemPackages = with pkgs; [
    # dev
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
    teams-for-linux
    telegram-desktop
    discord
    gqrx
    gimp
    ollama
    bitwarden-desktop

    # shell
    wget
    p7zip
    lolcat
    btop
  ];

  # Do not remove
  system.stateVersion = "24.05";
}
