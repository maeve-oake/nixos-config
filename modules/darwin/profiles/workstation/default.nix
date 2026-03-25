{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ./fish.nix
    ./system-defaults.nix
    ./user.nix
    ./apps.nix
  ];

  config = lib.mkIf config.profiles.workstation.enable {
    # nix-homebrew
    nix-homebrew = {
      user = config.me.username;
      enable = true;

      taps = with inputs; {
        "homebrew/homebrew-core" = homebrew-core;
        "homebrew/homebrew-cask" = homebrew-cask;
      };

      mutableTaps = false;
    };

    homebrew = {
      enable = true;
      onActivation = {
        cleanup = "zap";
        autoUpdate = true;
        upgrade = true;
      };

      taps = builtins.attrNames config.nix-homebrew.taps;
    };
  };
}
