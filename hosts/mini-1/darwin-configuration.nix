{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.self.darwinModules.default
  ];

  nixpkgs.config.permittedInsecurePackages = [
    # safe for private text-only use
    "exo-1.0.71"
  ];

  environment.systemPackages = with pkgs; [
    exo
  ];

  profiles.server.enable = true;

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Do not remove
  system.stateVersion = 6;
}
