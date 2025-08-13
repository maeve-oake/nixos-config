{
  inputs,
  pkgs,
  config,
  ...
}:
{
  age.secrets.maeve-password.file = (inputs.self + /secrets/maeve-password.age);

  users.mutableUsers = false;
  users.users.${config.me.username} = {
    isNormalUser = true;
    uid = 1000;
    group = "users";
    extraGroups = [
      "wheel" # sudo
      "networkmanager" # network configuration
      "video" # video
      "input" # three finger drag
      "vboxusers" # vbox
      "dialout" # serial
      "netbird" # netbird-ui
    ];

    shell = pkgs.fish;
    hashedPasswordFile = config.age.secrets.maeve-password.path;
    openssh.authorizedKeys.keys = [
      config.me.sshKey
    ];
  };

  users.groups.users.gid = 100;
}
