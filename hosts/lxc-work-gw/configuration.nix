{
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.default
  ];

  profiles.server.enable = true;

  age.secrets."lxc-work-gw/wireguard-priv" = { };

  networking = {
    useNetworkd = true;
    useHostResolvConf = false;

    bridges.br-home = {
      interfaces = [
        "eth0"
        "vxlan-work"
      ];
    };
    interfaces.br-home.useDHCP = true;
    interfaces.br-home.mtu = 1500;

    wireguard.interfaces.wg-work = {
      ips = [ "10.67.0.1/30" ];
      listenPort = 51111;
      mtu = 1550;
      privateKeyFile = config.age.secrets."lxc-work-gw/wireguard-priv".path;
      peers = [
        {
          publicKey = "ugWgSbrCKqdcJm/iyA8n2q4B2fO1F4dPlmWINETGjXw=";
          allowedIPs = [ "10.67.0.2/32" ];
        }
      ];
    };
  };

  systemd.network = {
    wait-online.anyInterface = true;

    links."10-br-home" = {
      matchConfig.OriginalName = "br-home";
      linkConfig.MACAddressPolicy = "none";
    };
    netdevs."40-br-home".netdevConfig = {
      Name = "br-home";
      Kind = "bridge";
      MACAddress = "none";
    };

    netdevs."20-vxlan-work" = {
      netdevConfig = {
        Kind = "vxlan";
        Name = "vxlan-work";
        MACAddress = "FE:FF:FF:67:67:67";
        MTUBytes = "1500";
      };
      vxlanConfig = {
        VNI = 100;
        Local = "10.67.0.1";
        Remote = "10.67.0.2";
        DestinationPort = 4789;
        Independent = true;
      };
      extraConfig = ''
        [VXLAN]
        IPDoNotFragment=no
      '';
    };
  };

  lxc = {
    enable = true;
    cores = 2;
    memory = 512;
    network = "vmbr1";
    pve.host = "kolibri.lan.ci";
  };

  system.stateVersion = "25.11";
}
