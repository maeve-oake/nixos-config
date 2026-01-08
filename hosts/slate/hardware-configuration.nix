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
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ./disk.nix
  ];

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  hardware.microsoft-surface.kernelVersion = "stable";

  services.iptsd.enable = lib.mkDefault true;
  environment.systemPackages = [ pkgs.surface-control ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024;
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
