{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.hyprland.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # fix electron blur
    QT_QPA_PLATFORMTHEME = "flatpak"; # fix telegram filepicker
  };

  environment.systemPackages = [
    pkgs.kitty
  ];
}
