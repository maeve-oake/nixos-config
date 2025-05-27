{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    # (inputs.self + /common/x86_64-linux/hyprland)
    (inputs.self + /common/x86_64-linux/secureboot.nix)
  ];

  # DE
  gnome.enable = true;
  gnome.dockItems.middle = [
    "teams-for-linux.desktop"
  ];

  # boot
  boot.kernelPackages = pkgs.linuxPackages_6_13;
  boot.loader.systemd-boot.configurationLimit = 1;

  # power & sleep
  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024;
    }
  ];
  systemd.sleep.extraConfig = ''
    		HibernateDelaySec=30m
    	'';
  services.logind.lidSwitch = "suspend-then-hibernate";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # fix electron blur
  };

  # fingerprint & login
  services.fprintd.enable = true;
  security.polkit.enable = true;

  # packages
  environment.systemPackages = with pkgs; [
    # apps
    teams-for-linux
  ];

  # Do not remove
  system.stateVersion = "24.05";
}
