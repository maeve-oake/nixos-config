{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.profiles.workstation.work-vpn.enable = lib.mkEnableOption "work VPN";

  config = lib.mkIf config.profiles.workstation.work-vpn.enable {
    profiles.workstation.enable = lib.mkForce true;

    networking.networkmanager.plugins = [
      pkgs.networkmanager-openconnect
    ];

    age.secrets.work-vpn = { };

    networking.networkmanager.ensureProfiles = {
      environmentFiles = [
        config.age.secrets.work-vpn.path
      ];

      profiles = {
        "work-vpn" = {
          connection = {
            id = "Work VPN";
            type = "vpn";
            autoconnect = "false";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            method = "disabled";
          };
          vpn = {
            authtype = "password";
            autoconnect-flags = 0;
            certsigs-flags = 0;
            cookie-flags = 2;
            disable_udp = "no";
            enable_csd_trojan = "no";
            gateway = "$WORK_VPN_GATEWAY";
            gateway-flags = 2;
            gwcert-flags = 2;
            lasthost-flags = 0;
            pem_passphrase_fsid = "no";
            prevent_invalid_cert = "no";
            protocol = "gp";
            resolve-flags = 2;
            stoken_source = "disabled";
            xmlconfig-flags = 0;
            service-type = "org.freedesktop.NetworkManager.openconnect";
          };
          vpn-secrets = {
            lasthost = "$WORK_VPN_GATEWAY";
            save_passwords = "yes";
          };
        };
      };
    };
  };
}
