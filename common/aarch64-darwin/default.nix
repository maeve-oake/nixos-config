{ pkgs, ... }:
{
  # common configuration for MacOS machines

  imports = [
    ../. # common/default.nix
    ./user.nix
  ];

  environment.systemPackages = with pkgs; [
    neovim
    gh
    git
    telegram-desktop
    nixpkgs-fmt
    vscode
    fzf
    zoxide
    p7zip
  ];
}
