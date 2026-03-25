{
  pkgs,
  ...
}:
{
  # homebrew.masApps = {
  #
  # };

  # pkgs
  environment.systemPackages = with pkgs; [
    # dev
    just
    nixfmt-rfc-style
    nixd
    nixpkgs-review
    neovim
    gh
    git

    # apps
    vscode
    discord
    gimp2
    spotify
    chatgpt

    # shell
    fzf
    nmap
    zoxide
    wget
    p7zip
  ];

  homebrew.casks = [
    # apps
    "microsoft-edge"
    "microsoft-outlook"
    "microsoft-teams"
    "windows-app"
    "telegram"
    "protonvpn"
  ];
}
