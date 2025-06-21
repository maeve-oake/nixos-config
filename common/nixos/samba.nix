{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  username = config.me.username;
  mynahOptions = [
    "x-systemd.automount"
    "noauto"
    "x-systemd.idle-timeout=5s"
    "x-systemd.device-timeout=5s"
    "x-systemd.mount-timeout=5s"
    "soft"
    "uid=${toString config.users.users.${username}.uid}"
    "gid=${toString config.users.groups.users.gid}"
  ];
in
{
  options.maeve.samba.enable = lib.mkEnableOption "mounting of Samba shares";

  config = lib.mkIf config.maeve.samba.enable {
    age.secrets.mynah-smb.file = (inputs.self + /secrets/mynah-smb.age);
    environment.systemPackages = with pkgs; [
      cifs-utils
      gocryptfs
    ];

    fileSystems = {
      "/mnt/mynah/maeve" = {
        device = "//anya-nas.maeve/maeve";
        fsType = "cifs";
        options = mynahOptions ++ [ "credentials=${config.age.secrets.mynah-smb.path}" ];
      };

      "/mnt/mynah/oake" = {
        device = "//anya-nas.maeve/oake";
        fsType = "cifs";
        options = mynahOptions ++ [ "credentials=${config.age.secrets.mynah-smb.path}" ];
      };
    };
  };
}
