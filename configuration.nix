{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./gnome.nix
    ];

  # allow unfree pkgs
  nixpkgs.config.allowUnfree = true;

  # systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # network
  networking.hostName = "replika";
  networking.networkmanager.enable = true;

  # localisation
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    keyMap = "uk";
  };
  time.timeZone = "Europe/London";
  services.xserver.xkb.layout = "gb";

  # power & sleep
  boot.resumeDevice = "/dev/disk/by-label/swap";
  boot.kernelParams = [
    "resume=LABEL=swap"
  ];
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
  '';
  services.logind.lidSwitch = "suspend-then-hibernate";
  services.logind.powerKey = "suspend-then-hibernate";
  services.logind.extraConfig = ''
    IdleAction=suspend-then-hibernate
  '';

  # shell
  programs.fish.enable = true;

  # environment variables
  environment.sessionVariables = { NIXOS_OZONE_WL = "1"; };

  # fingerprint (disabled until i encrypt my disk)
  # services.fprintd.enable = true;

  users.users.maeve = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;
  };

  # packages
  environment.systemPackages = with pkgs; [
    # dev
    git
    vscode
    neovim
    gh
    dotnet-sdk
    dotnet-runtime
    dotnet-aspnetcore

    # apps
    microsoft-edge
    telegram-desktop
    discord

    # shell
    wget
    lolcat
    zoxide
    fzf
  ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # Do not remove
  system.stateVersion = "24.05";
}
