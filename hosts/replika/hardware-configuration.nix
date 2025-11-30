{
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
  ];

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

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/acb6de3e-4f25-40fc-8deb-596e2d098cb9";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/6CBA-4177";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  boot.initrd.luks.devices."luks-5c6568a1-e289-4c4a-ba8a-e9630a66124e".device =
    "/dev/disk/by-uuid/5c6568a1-e289-4c4a-ba8a-e9630a66124e";

  swapDevices = [
    {
      device = "/swapfile";
      size = 64 * 1024;
    }
  ];

  # hardware.framework.laptop13.audioEnhancement.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
