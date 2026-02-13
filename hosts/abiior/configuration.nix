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
    laptop.enable = true;
    wifi.enable = true;
    gnome.enable = true;
  };

  # boot
  boot.kernelPackages = pkgs.linuxPackages_6_19;

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
