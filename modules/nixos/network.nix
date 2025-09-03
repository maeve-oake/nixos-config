{
  config,
  inputs,
  unstable,
  ...
}:
{
  networking.networkmanager.enable = true;

  # mdns
  services.avahi.enable = false;
  services.resolved.enable = true;

  # ssh
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # firewall
  networking.firewall.enable = false;

  # tailscale
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";

  # netbird
  age.secrets.netbird-personal = {
    file = (inputs.self + /secrets/netbird-personal.age);
    owner = "netbird";
    group = "netbird";
  };

  services.netbird = {
    simple = {
      enable = true;
      managementUrl = "https://net.oa.ke";
      setupKeyFile = config.age.secrets.netbird-personal.path;
    };

    package = unstable.netbird;
    ui.package = unstable.netbird-ui;
  };

  # wifi
  age.secrets.wifi-home.file = (inputs.self + /secrets/wifi-home.age);
  age.secrets.wifi-hotspot.file = (inputs.self + /secrets/wifi-hotspot.age);
  age.secrets.wifi-anna.file = (inputs.self + /secrets/wifi-anna.age);
  age.secrets.wifi-work.file = (inputs.self + /secrets/wifi-work.age);
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [
      config.age.secrets.wifi-home.path
      config.age.secrets.wifi-hotspot.path
      config.age.secrets.wifi-anna.path
      config.age.secrets.wifi-work.path
    ];

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
}
