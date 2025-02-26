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

  system.defaults = {
    CustomUserPreferences = {
      "com.apple.menuextra.clock" = {
        ShowSeconds = true;
      };
    };

    dock = {
      autohide = true;
      autohide-delay = 0.0;
      largesize = 72;
      orientation = "left";
      magnification = true;
      show-recents = false;
    };
  };
}
