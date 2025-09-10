{
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.default
  ];

  profiles.server.net-router = {
    enable = true;
    port = 30303;
  };

  lxc = {
    enable = true;
    network = "vmbr1"; # important! this is deployed to a router where vmbr0 is WAN
    pve.host = "kolibri." + config.me.lanDomain;
  };

  system.stateVersion = "25.11";
}
