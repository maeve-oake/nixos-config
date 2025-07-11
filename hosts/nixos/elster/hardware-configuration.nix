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

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/42a05164-1522-4459-b8fe-140b21233ea6";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/A3F1-A498";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  boot.initrd.luks.devices."luks-5f494377-e88e-4937-bb16-b2f7dd6033bf".device =
    "/dev/disk/by-uuid/5f494377-e88e-4937-bb16-b2f7dd6033bf";

  swapDevices = [
    {
      device = "/swapfile";
      size = 32 * 1024;
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
