{
  config,
  lib,
  ...
}:
{
  imports = [
    ./personal
    ./fish.nix
  ];

  config = lib.mkIf config.profiles.workstation.enable {
  };
}
