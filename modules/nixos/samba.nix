{
  pkgs,
  config,
  lib,
  ...
}:
let
  mkMounts =
    server: credentials: mounts:
    lib.attrsets.mapAttrs (name: share: {
      device = "//${server}/${share}";
      fsType = "cifs";
      options = [
        "x-systemd.automount"
        "noauto"
        "x-systemd.idle-timeout=5s"
        "x-systemd.device-timeout=5s"
        "x-systemd.mount-timeout=5s"
        "soft"
        "uid=${toString config.users.users.${config.me.username}.uid}"
        "gid=${toString config.users.groups.users.gid}"
        "credentials=${credentials}"
      ];
    }) mounts;
in
{
  options.maeve.samba.enable = lib.mkEnableOption "mounting of Samba shares";

  config = lib.mkIf config.maeve.samba.enable {
    age.secrets."samba-client/maeve-mynah" = { };
    age.secrets."samba-client/anna-mynah" = { };
    environment.systemPackages = with pkgs; [
      cifs-utils
      gocryptfs
    ];

    fileSystems =
      (mkMounts "share.lan.ci" config.age.secrets."samba-client/maeve-mynah".path {
        "/mnt/mynah/maeve" = "maeve";
      })
      // (mkMounts "share.lan.al" config.age.secrets."samba-client/anna-mynah".path {
        "/mnt/anna-mynah/maeve" = "maeve";
        "/mnt/anna-mynah/oake" = "oake";
      });
  };
}
