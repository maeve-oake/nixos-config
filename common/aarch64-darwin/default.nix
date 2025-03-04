{ pkgs, ... }:
{
  # common configuration for MacOS machines

  imports = [
    ./user.nix
  ];

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

  nix-homebrew = {
    user = "maeve";
    enable = true;
  };

  homebrew = {
    enable = true;
    casks = [
      "microsoft-edge"
    ];
  };

  system.defaults = {
    CustomUserPreferences = {
      "com.apple.menuextra.clock" = {
        ShowSeconds = true;
      };
    };

    dock = {
      autohide = true;
      autohide-delay = 0.0;
      largesize = 72; # magnification size
      tilesize = 28; # unmagnified size
      orientation = "left";
      magnification = true;
      show-recents = false;
    };
  };
}
