{ pkgs, ... }:
{
  # common configuration for MacOS machines

  imports = [
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
