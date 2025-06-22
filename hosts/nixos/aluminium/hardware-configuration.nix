{
  config,
  lib,
  ...
}:
{
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/af53ae23-30d3-4973-9aed-cc2483a5c8ff";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-4f6cfa75-5ad0-402c-8b81-00fca91b593e".device =
    "/dev/disk/by-uuid/4f6cfa75-5ad0-402c-8b81-00fca91b593e";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2EE3-ED1E";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
