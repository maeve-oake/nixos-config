{
  inputs,
  hostName,
  ...
}:
{
  # common configuration for all architectures
  # please see subdirectories for OS-specific configuration

  imports = [
    inputs.nix-things.commonModules.default
  ];

  # networking
  networking.hostName = hostName;

  system.configurationRevision = inputs.self.rev or "dirty";
}
