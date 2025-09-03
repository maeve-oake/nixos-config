{
  inputs,
  lib,
  unstable,
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

  lxc.pve.host = lib.mkDefault "mynah.lan.ci";
}
