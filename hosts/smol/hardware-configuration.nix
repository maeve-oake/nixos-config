{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.microsoft-surface-common
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
  ];

  disko.simple = {
    device = "/dev/mmcblk0";
    luks = true;
  };

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  hardware.microsoft-surface.kernelVersion = "stable";

  services.iptsd.enable = lib.mkDefault true;
  environment.systemPackages = [ pkgs.surface-control ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "usbhid"
  ];
  boot.initrd.kernelModules = [
    "sdhci_pci"
    "rtsx_pci_sdmmc"
    "dm_mod"
    "dm_crypt"
  ];

  boot.kernelModules = [ "kvm-intel" ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
