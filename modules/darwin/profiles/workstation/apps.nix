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
    # apps
    discord
    spotify
    chatgpt
    ollama

    # shell
    fzf
    zoxide
  ];

  services.netbird.enable = true;

  homebrew.casks = [
    # apps
    "microsoft-edge"
    "microsoft-outlook"
    "microsoft-teams"
    "windows-app"
    "telegram"
    "protonvpn"
    "plex"
    "affinity"
    "bambu-studio"
  ];
}
