{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    ;
  cfg = config.hardware.isight;
in
{
  options.hardware.isight = {
    enable = mkEnableOption "support for Apple iSight FireWire camera";
  };

  config = mkIf cfg.enable {
    boot.kernelModules = [ "firewire_ohci" ];
    boot.initrd.luks.mitigateDMAAttacks = false; # it's fiiiiiiiiine
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=0
    '';

    services.v4l2-relayd.instances.isight = {
      enable = mkDefault true;

      cardLabel = mkDefault "Apple iSight";

      input = {
        pipeline = "dc1394src ! video/x-raw,width=640,height=480,framerate=30/1 ! videoconvert";
        format = "YUY2";
        width = 640;
        height = 480;
        framerate = 30;
      };
    };
  };
}
