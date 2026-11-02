{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.self.darwinModules.default
  ];

  environment.systemPackages = with pkgs; [
    exo
  ];

  profiles.server.enable = true;

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Do not remove
  system.stateVersion = 6;
}
