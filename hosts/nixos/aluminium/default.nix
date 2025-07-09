{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # DE
  gnome.enable = true;
  gnome.dockItems.middle = [
    "teams-for-linux.desktop"
  ];

  # boot
  boot.secureboot.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_6_15;
  boot.loader.systemd-boot.configurationLimit = 1;

  # power & sleep
  systemd.sleep.extraConfig = ''
    		HibernateDelaySec=30m
    	'';
  services.logind.lidSwitch = "suspend-then-hibernate";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # fix electron blur
  };

  # fingerprint & login
  security.polkit.enable = true;

  # packages
  environment.systemPackages = with pkgs; [
    # apps
    teams-for-linux
  ];

  # Do not remove
  system.stateVersion = "24.05";
}
