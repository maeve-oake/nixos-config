{
  config,
  lib,
  ...
}:
{
  disko.simple = {
    device = "/dev/disk/by-id/nvme-Predator_SSD_GM7000_2TB_PSAG55030100310";
    luks = true;
  };

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "sd_mod"
    "ahci"
    "firewire_ohci"
    "usbhid"
  ];
  boot.kernelModules = [ "kvm-amd" ];

  swapDevices = [
    {
      device = "/swapfile";
      size = 32 * 1024;
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
