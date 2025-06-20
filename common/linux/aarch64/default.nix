{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # apps
    legcord
  ];
}
