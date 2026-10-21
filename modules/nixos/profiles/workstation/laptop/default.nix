{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isx86_64;
in
{
  options.profiles.workstation.laptop.enable = lib.mkEnableOption "Laptop workstation profile";

  config = lib.mkIf config.profiles.workstation.laptop.enable {
    profiles.workstation.enable = lib.mkForce true;

    # TODO: remove once merged https://github.com/NixOS/nixpkgs/pull/575818
    nixpkgs.overlays = [
      (_final: prev: {
        linuxPackages_latest = prev.linuxPackages_latest.extend (
          _finalKernel: prevKernel: {
            framework-laptop-kmod = prevKernel.framework-laptop-kmod.overrideAttrs {
              installPhase = null;
              installTargets = [ "modules_install" ];
              installFlags = [
                "INSTALL_MOD_PATH=$(out)"
                "INSTALL_MOD_DIR=extra"
                "DEPMOD=true"
              ];
            };
          }
        );
      })
    ];

    systemd.sleep.settings.Sleep.HibernateDelaySec = lib.mkIf isx86_64 "4h";
    services.logind.settings.Login.HandleLidSwitch = lib.mkIf isx86_64 "suspend-then-hibernate";
  };
}
