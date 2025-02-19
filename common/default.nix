{ pkgs, ... }:
{
  # allow unfree pkgs
  nixpkgs.config.allowUnfree = true;

  # pkgs
  programs.fish.enable = true;
  environment.systemPackages = with pkgs; [
    # dev
    git

    # shell
    fzf
    zoxide
  ];
}
