{
  inputs,
  unstable,
  ...
}:
{
  disabledModules = [
    "services/networking/netbird.nix"
  ];

  imports = [
    "${inputs.nix-unstable}/nixos/modules/services/networking/netbird.nix"
  ];

  services.netbird = {
    package = unstable.netbird;
    ui.package = unstable.netbird-ui;
  };
}
