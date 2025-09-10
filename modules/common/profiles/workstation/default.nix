{
  config,
  lib,
  ...
}:
{
  imports = [
    ./fish.nix
  ];

  config = lib.mkIf config.profiles.workstation.enable {
  };
}
