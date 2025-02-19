{ pkgs, ... }:
{
  imports = [
    ./git.nix
    ./fish.nix
    ./zoxide.nix
  ];

  # allow unfree pkgs
  nixpkgs.config.allowUnfree = true;
}
