{
  config,
  lib,
  ...
}:
{
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

  disko.simple = {
    device = "/dev/nvme0n1";
    luks = true;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 32 * 1024;
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
