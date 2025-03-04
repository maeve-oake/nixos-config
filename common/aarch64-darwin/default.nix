{ pkgs, ... }:
{
  # common configuration for MacOS machines

  imports = [
    ./user.nix
    ./system-defaults.nix
  ];

  # nix-homebrew
  nix-homebrew = {
    user = "maeve";
    enable = true;
  };

  # pkgs
  environment.systemPackages = with pkgs; [
    # dev
    nixpkgs-fmt
    vscode
    neovim
    gh
    git

    # apps
    telegram-desktop

    # shell
    fzf
    zoxide
    p7zip
  ];

  homebrew = {
    enable = true;
    casks = [
      "microsoft-edge"
      "ilya-birman-typography-layout"
    ];
  };
}
