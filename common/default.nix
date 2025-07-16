{
  inputs,
  hostname,
  pkgs,
  ...
}:
{
  # common configuration for all architectures
  # please see subdirectories for OS-specific configuration

  imports = [
    ./fish.nix
    ./me.nix
    ./nix.nix
    inputs.agenix.nixosModules.default
    inputs.nix-things.commonModules.default
  ];

  # age
  environment.systemPackages = [
    pkgs.agenix
  ];

  # networking
  networking.hostName = hostname;

  system.configurationRevision = inputs.self.rev or "dirty";
}
