{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./fish.nix
    ./system-defaults.nix
    ./apps.nix
  ];
}
