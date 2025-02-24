{ pkgs, ... }:
{
  # common configuration for MacOS machines

  imports = [
    ../. # common/default.nix
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
    lolcat
    p7zip
  ];
}
