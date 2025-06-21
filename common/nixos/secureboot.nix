{
  lib,
  config,
  ...
}:
{
  options.boot.secureboot = lib.mkEnableOption "Secure Boot";
  config = lib.mkIf config.boot.secureboot {
    boot.initrd.systemd.enable = true;
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.bootspec.enable = true;
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };
}
