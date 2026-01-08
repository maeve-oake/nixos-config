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

  # packages
  environment.systemPackages = with pkgs; [
    # apps
    darktable
  ];

  # Do not remove
  system.stateVersion = "25.11";
}
