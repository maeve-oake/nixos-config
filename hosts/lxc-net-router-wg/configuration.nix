{
  inputs,
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

  deploy.fqdn = "10.64.3.6";

  system.stateVersion = "25.11";
}
