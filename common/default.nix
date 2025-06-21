{
  inputs,
  hostname,
  pkgs,
  ...
}:
{
  # common configuration for all architectures
  # please see subdirectories for arch-specific configuration

  imports = [
    ./fish.nix
    ./nix.nix
    inputs.agenix.nixosModules.default
  ];

  # age
  environment.systemPackages = [
    pkgs.agenix
  ];

  # networking
  networking.hostName = hostname;

  system.configurationRevision = inputs.self.rev or "dirty";
}
