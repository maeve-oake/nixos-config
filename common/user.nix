{ pkgs, ... }:
{
  users.users.maeve = {
    isNormalUser = true;
    uid = 1000;
    group = "users";
    extraGroups = [
      "wheel" # sudo
      "networkmanager" # network configuration
      "video" #
      "input" # three finger drag
      "vboxusers" # vbox
    ];

    shell = pkgs.fish;
  };

  users.groups.users.gid = 100;
}
