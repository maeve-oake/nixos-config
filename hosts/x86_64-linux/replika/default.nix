{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    (inputs.self + /common/x86_64-linux/gnome)
    (inputs.self + /common/x86_64-linux/secureboot.nix)
    (inputs.self + /common/x86_64-linux/samba.nix)
  ];

  # boot
  boot.kernelPackages = pkgs.linuxPackages_6_14;

  # networking
  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="GB"
  '';

  # power & sleep
  swapDevices = [
    {
      device = "/swapfile";
      size = 64 * 1024;
    }
  ];
  boot.kernelParams = [
    "amd_pstate=guided"
  ];
  systemd.sleep.extraConfig = ''
    		HibernateDelaySec=30m
    	'';
  services.logind.lidSwitch = "suspend-then-hibernate";
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;
  boot.kernelModules = [
    "amd_pstate"
    "amd_pstate_ut"
  ];

  # udev rules
  services.udev.extraRules = ''
    # give vboxusers raw access to Windows 1TB module
    SUBSYSTEM=="block", KERNEL=="sd?", ATTRS{serial}=="071C435B161FE558", MODE="0660", GROUP="vboxusers", SYMLINK+="windows-module-disk"
  '';

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # fix electron blur
  };

  # fingerprint & login
  services.fprintd.enable = true;
  security.polkit.enable = true;

  # packages
  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    # apps
    gqrx
    plex-desktop
    ollama
    darktable
    satdump
  ];

  # Do not remove
  system.stateVersion = "24.05";
}
