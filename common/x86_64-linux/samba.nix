{ pkgs, config, ... }:
let
  mynahOptions = [
    "x-systemd.automount"
    "noauto"
    "x-systemd.idle-timeout=5s"
    "x-systemd.device-timeout=5s"
    "x-systemd.mount-timeout=5s"
    "soft"
    "uid=${toString config.users.users.maeve.uid}"
    "gid=${toString config.users.groups.users.gid}"
  ];
in
{
  age.secrets.mynah-smb.file = ../../secrets/mynah-smb.age;
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
}
