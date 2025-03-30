{ pkgs, ... }:
{
  # common configuration for MacOS machines

  imports = [
    ./user.nix
    ./system-defaults.nix
  ];

  # tailscale
  services.tailscale.enable = true;

  # nix-homebrew
  nix-homebrew = {
    user = "maeve";
    enable = true;
  };

  /*
    TODO: investigate linking apps from the nix store to spotlight / environment and have then indexed
          currently, apps installed via Brew do show up properly but ones installed via Nix must be launched from /Applications/Nix Apps
          vscode seems to have some issues when installed via nix (asks for helper script installs on every reboot)

          they ARE linked in /Applications/Nix apps, so i guess we just need to get it to *actually index*?

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
    discord
    raycast
    gimp

    # shell
    fzf
    nmap
    zoxide
    wget
    p7zip
  ];

  homebrew = {
    enable = true;
    casks = [
      # dev
      "visual-studio-code"

      # apps
      "microsoft-edge"
      "telegram"
      "autodesk-fusion"
      "ultimaker-cura"

      # system
      "ilya-birman-typography-layout"
    ];
  };
}
