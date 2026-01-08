{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.default
    ./hardware-configuration.nix
    inputs.apple-silicon-support.nixosModules.apple-silicon-support
  ];

  profiles.workstation = {
    enable = true;
    wifi.enable = true;
  };

  hardware.asahi.peripheralFirmwareDirectory = ./firmware;

  # DE
  profiles.workstation.gnome = {
    enable = true;
    dockItems.left = [
      "firefox.desktop"
      "org.telegram.desktop.desktop"
      "legcord.desktop"
    ];
  };

  boot.extraModprobeConfig = ''
    options hid_apple iso_layout=1
  '';

  system.stateVersion = "25.11";
}
