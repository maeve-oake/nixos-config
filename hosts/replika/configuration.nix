{
  inputs,
  pkgs,
  ...
}:
let
  miaow = inputs.miaow.packages.${pkgs.system}.default;
in
{
  imports = [
    inputs.self.nixosModules.default
    ./hardware-configuration.nix
  ];

  profiles.workstation = {
    enable = true;
    laptop.enable = true;
    samba.enable = true;
    wifi.enable = true;
    gnome = {
      enable = true;
      dockItems.middle = [ "ke.oa.miaow.desktop" ];
      shellExtensions = [ miaow ];
    };
    work-vpn.enable = true;
  };

  # boot
  boot.kernelPackages = pkgs.linuxPackages_7_1;

  # power & sleep
  networking.networkmanager.wifi.powersave = true;

  # udev rules
  services.udev.extraRules = ''
    # give vboxusers raw access to Windows 1TB module
    SUBSYSTEM=="block", KERNEL=="sd?", ATTRS{serial}=="071C435B161FE558", MODE="0660", GROUP="vboxusers", SYMLINK+="windows-module-disk"
  '';

  services.udev.extraHwdb = ''
    # disable Framework F10 airplane mode key
    evdev:input:b0018v32ACp0006*
     KEYBOARD_KEY_100c6=rotate_display
  '';

  # please stop crashing
  boot.kernelParams = [
    "amdgpu.dcdebugmask=0x10"
  ];

  hardware.rtl-sdr.enable = true;

  users.users.maeve.extraGroups = [
    "plugdev"
  ];

  # fingerprint & login
  security.polkit.enable = true;

  programs.framework-privacy-bar.enable = true;

  # packages
  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    # apps
    miaow
    calls
    gqrx
    plex-desktop
    ollama
    darktable
    satdump
  ];

  # Do not remove
  system.stateVersion = "24.05";
}
