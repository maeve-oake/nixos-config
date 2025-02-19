{ pkgs, ... }:
{
  imports = [
    ./fish.nix
  ];

  # allow unfree pkgs
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # dev
    git

    # shell
    fzf
    zoxide
  ];
}
