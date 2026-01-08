{
  inputs,
  pkgs,
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
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # power & sleep
  systemd.sleep.extraConfig = "HibernateDelaySec=4h";
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  networking.networkmanager.wifi.powersave = true;

  # udev rules
  services.udev.extraRules = ''
    # give vboxusers raw access to Windows 1TB module
    SUBSYSTEM=="block", KERNEL=="sd?", ATTRS{serial}=="071C435B161FE558", MODE="0660", GROUP="vboxusers", SYMLINK+="windows-module-disk"
  '';

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
    satdump
  ];

  # Do not remove
  system.stateVersion = "24.05";
}
