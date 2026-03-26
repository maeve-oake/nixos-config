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
    gimp2
    spotify
    chatgpt
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
