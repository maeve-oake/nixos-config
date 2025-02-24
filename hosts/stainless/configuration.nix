{ pkgs, ... }: {
  imports = [
    ../../common/fish.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  system.stateVersion = 5;

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
