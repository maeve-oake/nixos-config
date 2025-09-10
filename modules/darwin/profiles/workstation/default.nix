{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ./fish.nix
    ./system-defaults.nix
    ./user.nix
  ];

  config = lib.mkIf config.profiles.workstation.enable {
    # tailscale
    services.tailscale.enable = true;

    # nix-homebrew
    nix-homebrew = {
      user = config.me.username;
      enable = true;

      taps = with inputs; {
        "homebrew/homebrew-core" = homebrew-core;
        "homebrew/homebrew-cask" = homebrew-cask;
      };

      mutableTaps = false;
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
      onActivation.cleanup = "zap";
      taps = builtins.attrNames config.nix-homebrew.taps;

      casks = [
        # dev
        "visual-studio-code"

        # apps
        "microsoft-edge"
        "telegram"
        "autodesk-fusion"

        # system
        "ilya-birman-typography-layout"
      ];
    };
  };
}
