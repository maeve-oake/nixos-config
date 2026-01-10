{
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
  ];

  disko.simple = {
    device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_S7KHNU0X505977X";
    luks = true;
  };

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "sd_mod"
    "thunderbolt"
  ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = lib.mkAfter [
    "amdgpu.dcdebugmask=0"
  ];

  swapDevices = [
    {
      device = "/swapfile";
      size = 64 * 1024;
    }
  ];

  # hardware.framework.laptop13.audioEnhancement.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
