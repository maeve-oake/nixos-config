{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.profiles.workstation.enable {
    age.secrets.maeve-password = { };

    users.users.maeve = {
      isNormalUser = true;
      uid = 1000;
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
        config.me.wifeKey
      ];
    };
  };
}
