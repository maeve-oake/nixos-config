{
  inputs,
  lib,
  unstable,
  config,
  ...
}:
{
  imports = [
    inputs.self.commonModules.default
    inputs.nix-things.lxcModules.default
  ];

  services.netbird = {
    package = unstable.netbird;
    ui.package = unstable.netbird-ui;
  };

  lxc.pve.host = lib.mkDefault "mynah." + config.me.lanDomain;
}
