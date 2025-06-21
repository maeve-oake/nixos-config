{
  config,
  lib,
  ...
}:
{
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-amd" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/acb6de3e-4f25-40fc-8deb-596e2d098cb9";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-5c6568a1-e289-4c4a-ba8a-e9630a66124e".device =
    "/dev/disk/by-uuid/5c6568a1-e289-4c4a-ba8a-e9630a66124e";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6CBA-4177";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
