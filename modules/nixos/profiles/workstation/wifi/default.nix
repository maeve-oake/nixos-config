{
  config,
  lib,
  ...
}:
let
  wifiSecrets = [
    "home"
    "hotspot"
    "anna"
    "work"
  ];
in
{
  options.profiles.workstation.wifi.enable = lib.mkEnableOption "Wi-Fi workstation profile";

  config = lib.mkIf config.profiles.workstation.wifi.enable {
    profiles.workstation.enable = lib.mkForce true;

    boot.extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom="GB"
    '';

    age.secrets = lib.genAttrs (map (name: "wifi/${name}") wifiSecrets) (_: { });

    # wifi
    networking.networkmanager.ensureProfiles = {
      environmentFiles = map (name: config.age.secrets."wifi/${name}".path) wifiSecrets;

      profiles = {
        Home = {
          connection = {
            id = "$HOME_SSID";
            type = "wifi";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "$HOME_SSID";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$HOME_PSK";
          };
        };

        Hotspot = {
          connection = {
            id = "$HOTSPOT_SSID";
            type = "wifi";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "$HOTSPOT_SSID";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$HOTSPOT_PSK";
          };
        };

        Anna = {
          connection = {
            id = "$ANNA_SSID";
            type = "wifi";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "$ANNA_SSID";
          };
          wifi-security = {
            key-mgmt = "sae";
            psk = "$ANNA_PSK";
          };
        };

        Work = {
          connection = {
            id = "$WORK_SSID";
            type = "wifi";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "$WORK_SSID";
          };
          wifi-security = {
            key-mgmt = "wpa-eap";
            auth-alg = "open";
          };
          "802-1x" = {
            domain-suffix-match = "$WORK_DOMAIN";
            eap = "peap";
            identity = "$WORK_USERNAME";
            password = "$WORK_PASSWORD";
            phase2-auth = "mschapv2";
          };
        };
      };
    };
  };
}
