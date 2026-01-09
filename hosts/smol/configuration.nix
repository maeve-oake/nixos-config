{
  inputs,
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

  # Do not remove
  system.stateVersion = "25.11";
}
