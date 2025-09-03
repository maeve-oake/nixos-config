{
  inputs,
  hostName,
  pkgs,
  ...
}:
{
  # common configuration for all architectures
  # please see subdirectories for OS-specific configuration

  imports = [
    inputs.agenix.nixosModules.default
    inputs.nix-things.commonModules.default
  ];

  # age
  environment.systemPackages = [
    pkgs.agenix
  ];

  # networking
  networking.hostName = hostName;

  system.configurationRevision = inputs.self.rev or "dirty";
}
