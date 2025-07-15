{
  inputs,
  config,
  pkgs,
  ...
}:
{
  # cache
  nix.settings.extra-substituters = [
    "https://attic.oa.ke/nixos"
  ];
  nix.settings.extra-trusted-public-keys = [
    "nixos:qbhh36l2BlhnNhXnU0I2XHOzIT3mzwxKfs86C4am5aY="
  ];
  age.secrets.attic-netrc.file = (inputs.self + /secrets/attic-netrc.age);
  nix.settings.netrc-file = config.age.secrets.attic-netrc.path;

  # overlays
  nixpkgs.overlays = [
    inputs.nix-vscode-extensions.overlays.default
    inputs.agenix.overlays.default
    (import (inputs.self + /pkgs))
  ];
}
