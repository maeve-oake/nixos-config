{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.darwinModules.default
  ];

  environment.systemPackages = [
    inputs.exo.packages.aarch64-darwin.exo
  ];

  profiles.server.enable = true;

  services.netbird.enable = true;

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Do not remove
  system.stateVersion = 6;
}
