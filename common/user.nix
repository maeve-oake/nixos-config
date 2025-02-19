{ pkgs, ... }:
{
  programs.fish.enable = true;

  users.users.maeve = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # sudo
      "networkmanager" # network configuration
      "video" #
      "input" # three finger drag
      "vboxusers" # vbox
    ];

    shell = pkgs.fish;
  };
}
