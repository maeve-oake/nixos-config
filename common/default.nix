{ pkgs, ... }:
{
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
