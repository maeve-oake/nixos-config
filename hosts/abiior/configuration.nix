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
    wifi.enable = true;
    gnome.enable = true;
  };

  # boot
  boot.secureboot.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # power & sleep
  systemd.sleep.extraConfig = "HibernateDelaySec=4h";
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  networking.networkmanager.wifi.powersave = true;

  # fingerprint & login
  security.polkit.enable = true;

  # packages
  environment.systemPackages = with pkgs; [
    # apps
    gqrx
    darktable
    satdump
  ];

  # Do not remove
  system.stateVersion = "25.11";
}
