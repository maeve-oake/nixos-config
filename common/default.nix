{
  # common configuration for all architectures
  # please see subdirectories for arch-specific configuration

  imports = [
    ./user.nix
    ./fish.nix
  ];

  # allow unfree pkgs
  nixpkgs.config.allowUnfree = true;

  # flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
