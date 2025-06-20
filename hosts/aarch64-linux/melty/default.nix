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
  gnome.dockItems.left = [
    "firefox.desktop"
    "org.telegram.desktop.desktop"
    "legcord.desktop"
    "element-desktop.desktop"
  ];

  boot.extraModprobeConfig = ''
    options hid_apple iso_layout=1
  '';

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # fix electron blur
  };

  system.stateVersion = "25.11";
}
