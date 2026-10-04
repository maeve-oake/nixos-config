{
  config,
  inputs,
  lib,
  ...
}:
let
  common = import ./common.nix;

  phone = extra: lib.recursiveUpdate common extra;

  devices =
    lib.mapAttrs'
      (file: type: {
        name = lib.removeSuffix ".nix" file;
        value = phone (import (./phones + "/${file}"));
      })
      (
        lib.filterAttrs (file: type: type == "regular" && lib.hasSuffix ".nix" file) (
          builtins.readDir ./phones
        )
      );
in
{
  imports = [
    inputs.self.nixosModules.default
  ];

  profiles.server.enable = true;

  age.secrets."lxc-phones/cisco-secrets" = { };
  age.secrets."lxc-phones/beesly-ha-token" = { };
  age.secrets."lxc-phones/beesly-ami-password" = { };

  services.beesly = {
    enable = true;
    homeAssistant = {
      url = "https://ha.birb.cc";
      tokenFile = config.age.secrets."lxc-phones/beesly-ha-token".path;
      entities = [
        "light.living_room_floor_lamp"
        "climate.aircon"
      ];
    };
    ami = {
      host = "h.koteeq.me";
      username = "beesly";
      passwordFile = config.age.secrets."lxc-phones/beesly-ami-password".path;
      slots = {
        "01" = "light.living_room_floor_lamp";
        "02" = "climate.aircon";
      };
    };
  };

  services.cisco = {
    enable = true;
    extraAllowedClients = [
      "10.0.0.11" # replika
      "10.0.0.10" # elster
    ];

    secretsPath = config.age.secrets."lxc-phones/cisco-secrets".path;

    ringtones = {
      "Penis" = ./ringtones/penis.raw;
    };

    inherit devices;
  };

  lxc.enable = true;

  system.stateVersion = "25.11";
}
