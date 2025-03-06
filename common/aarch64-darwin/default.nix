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

  /*
    TODO: investigate linking apps from the nix store to spotlight / environment
          currently, apps installed via Brew do show up properly but ones installed via Nix must be found in the store and then added to dock / indexed manually
          vscode seems to have some issues when installed via nix (asks for helper script installs on every reboot) and discord has JS crashes

          If brew just turns out to be better, look into immutable taps! this will provide the immutability of Nix without the problems of nixpkgs
  */

  # pkgs
  environment.systemPackages = with pkgs; [
    # dev
    nixpkgs-fmt
    neovim
    gh
    git

    # apps
    telegram-desktop

    # shell
    fzf
    zoxide
    p7zip

    # system
    raycast
  ];

  homebrew = {
    enable = true;
    casks = [
      # dev
      "visual-studio-code"

      # apps
      "microsoft-edge"
      "discord"

      # system
      "ilya-birman-typography-layout"
    ];
  };
}
