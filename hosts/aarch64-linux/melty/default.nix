{ inputs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.apple-silicon-support.nixosModules.apple-silicon-support
  ];

  hardware.asahi.peripheralFirmwareDirectory = ./firmware;
  hardware.asahi.useExperimentalGPUDriver = true;

  # DE
  gnome.enable = true;

  boot.extraModprobeConfig = ''
    options hid_apple iso_layout=1
  '';

  system.stateVersion = "25.11";
}
