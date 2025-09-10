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
    port = 30304;
  };

  lxc.enable = true;

  system.stateVersion = "25.11";
}
