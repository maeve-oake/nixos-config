{
  inputs,
  ...
}:
let
  inherit (inputs.nix-things.lib.disko) mkDiskExt4InLuks;
in
{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  disko.devices.disk = {
    main = mkDiskExt4InLuks "/dev/nvme0n1";
  };
}
