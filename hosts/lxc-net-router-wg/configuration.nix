{
  inputs,
  lib,
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
    pve.host = "10.64.0.2";
  };

  deploy.fqdn = "wg-router.me.ow";

  monitoring.metrics.namePrefixes = lib.mkForce [
    "vineta"
    "prox-wg"
  ];

  system.stateVersion = "25.11";
}
