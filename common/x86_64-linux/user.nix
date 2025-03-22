{ pkgs, config, ... }:
{
  age.secrets.maeve-password.file = ../../secrets/maeve-password.age;

  users.mutableUsers = false;
  users.users.maeve = {
    isNormalUser = true;
    uid = 1000;
    group = "users";
    extraGroups = [
      "wheel" # sudo
      "networkmanager" # network configuration
      "video"
      "input" # three finger drag
      "vboxusers" # vbox
    ];

    shell = pkgs.fish;
    hashedPasswordFile = config.age.secrets.maeve-password.path;
  };

  users.groups.users.gid = 100;
}
