{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.nvidia.gpuUnlock;
  package = config.boot.kernelPackages.callPackage ./package.nix { };
in
{
  options.hardware.nvidia.gpuUnlock = {
    enable = lib.mkEnableOption "the experimental pre-driver NVIDIA FP16/BF16 tensor compute unlock";
    targets = lib.mkOption {
      type = lib.types.either (lib.types.enum [ "all" ]) (
        lib.types.listOf (lib.types.strMatching "[[:xdigit:]]{4}:[[:xdigit:]]{2}:[[:xdigit:]]{2}\\.[0-7]")
      );
      default = "all";
      example = [ "0000:01:00.0" ];
      description = ''
        Supported GPUs to unlock: all, or full PCI addresses from lspci -D.
        Supports upstream's listed RTX 20/30/40 cards, including the RTX 3080.
        This improves suitable tensor workloads, not general graphics performance.
      '';
    };
    resume = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Reapply the unlock after suspend to RAM. Requires NVIDIA kernel suspend
        notifiers; hibernation is not supported by upstream.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.hardware.nvidia.enabled && pkgs.stdenv.hostPlatform.system == "x86_64-linux";
        message = "gpuUnlock requires the NVIDIA driver on x86_64-linux.";
      }
      {
        assertion = cfg.targets == "all" || cfg.targets != [ ];
        message = "gpuUnlock.targets must be all or a nonempty list of PCI addresses.";
      }
      {
        assertion = cfg.resume -> config.hardware.nvidia.powerManagement.kernelSuspendNotifier;
        message = "gpuUnlock.resume requires hardware.nvidia.powerManagement.kernelSuspendNotifier.";
      }
    ];

    boot.extraModulePackages = [ package ];
    hardware.firmware = [ package.firmware ];
    boot.kernelParams = [
      "gpu_unlock.targets=${if cfg.targets == "all" then "all" else lib.concatStringsSep "," cfg.targets}"
    ]
    ++ lib.optional (!cfg.resume) "gpu_unlock.resume=0";

    # MODULE_FIRMWARE declarations pull the required blobs into the initrd.
    boot.initrd.availableKernelModules = [ "gpu_unlock" ];

    # systemd-modules-load and udev can otherwise race each other. Complete the
    # unlock before either can load nvidia (including early KMS configurations).
    boot.initrd.systemd.services.gpu-unlock = {
      description = "Unlock NVIDIA tensor compute before NVIDIA binds";
      wantedBy = [ "sysinit.target" ];
      before = [
        "systemd-modules-load.service"
        "systemd-udevd.service"
        "systemd-udev-trigger.service"
      ];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.kmod}/bin/modprobe gpu_unlock";
      };
    };
  };
}
