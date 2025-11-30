{
  inputs,
  pkgs,
  unstable,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.default
    ./hardware-configuration.nix
  ];

  profiles.workstation = {
    enable = true;
    samba.enable = true;
    wifi.enable = true;
    gnome.enable = true;
  };

  # boot
  boot.secureboot.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_6_17;

  # power & sleep
  systemd.sleep.extraConfig = "HibernateDelaySec=4h";
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  networking.networkmanager.wifi.powersave = true;

  # udev rules
  services.udev.extraRules = ''
    # give vboxusers raw access to Windows 1TB module
    SUBSYSTEM=="block", KERNEL=="sd?", ATTRS{serial}=="071C435B161FE558", MODE="0660", GROUP="vboxusers", SYMLINK+="windows-module-disk"
  '';

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # fix electron blur
  };

  # fingerprint & login
  security.polkit.enable = true;

  # packages
  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    # apps
    gqrx
    plex-desktop
    ollama
    darktable
    unstable.satdump
  ];

  # Do not remove
  system.stateVersion = "24.05";
}
