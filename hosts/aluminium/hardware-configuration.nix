{
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-intel-core-ultra-series1
  ];

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "sd_mod"
    "thunderbolt"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/af53ae23-30d3-4973-9aed-cc2483a5c8ff";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/2EE3-ED1E";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  boot.initrd.luks.devices."luks-4f6cfa75-5ad0-402c-8b81-00fca91b593e".device =
    "/dev/disk/by-uuid/4f6cfa75-5ad0-402c-8b81-00fca91b593e";

  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024;
    }
  ];

  hardware.framework.laptop13.audioEnhancement = {
    enable = true;
    rawDeviceName = "alsa_output.pci-0000_00_1f.3.analog-stereo";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
