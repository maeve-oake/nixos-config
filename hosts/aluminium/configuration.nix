{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/x86_64-linux/gnome
    ../../common/x86_64-linux/secureboot.nix
  ];

  # boot
  boot.loader.timeout = 0;
  boot.kernelPackages = pkgs.linuxPackages_6_13;

  # network
  networking.hostName = "aluminium";

  # power & sleep
  swapDevices = [{ device = "/swapfile"; size = 16 * 1024; }];
  systemd.sleep.extraConfig = ''
    		HibernateDelaySec=30m
    	'';
  services.logind.lidSwitch = "suspend-then-hibernate";

  # fingerprint & login
  services.fprintd.enable = true;
  security.polkit.enable = true;

  # packages
  environment.systemPackages = with pkgs; [
    # apps
    teams-for-linux
  ];

  nixpkgs.overlays = [
    (final: prev: {
      # overlay to fix microsoft edge sync w/ aad accounts
      # https://github.com/NixOS/nixpkgs/issues/343401#issuecomment-2692747174
      microsoft-edge = prev.microsoft-edge.overrideAttrs
        (old: (
          let
            deps = [
              # extra dependencies for libmip_core/libmip_protection_sdk
              final.libsecret
              final.glib
              final.stdenv.cc.cc.lib
              final.libxml2
              final.libuuid
            ];
          in
          {
            rpath = old.rpath + ":" + lib.makeLibraryPath deps + ":" + lib.makeSearchPathOutput "lib" "lib64" deps;
            binpath = old.binpath + ":" + lib.makeBinPath deps;

            installPhase = (
              builtins.replaceStrings [ "--prefix XDG_" ] [
                ''--set SSL_CERT_FILE "${final.cacert}/etc/ssl/certs/ca-bundle.crt" --prefix XDG_''
              ]
                old.installPhase
            );
          }
        ));
    })
  ];

  # Do not remove
  system.stateVersion = "24.05";
}
