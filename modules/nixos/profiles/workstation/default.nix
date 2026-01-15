{
  inputs,
  config,
  lib,
  hostName,
  pkgs,
  onlyArm,
  onlyX86,
  ...
}:
{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nix-flatpak.nixosModules.nix-flatpak
    ./gnome
    ./laptop
    ./samba
    ./wifi
    ./fish.nix
    ./localisation.nix
    ./network.nix
    ./user.nix
  ];

  config = lib.mkIf config.profiles.workstation.enable {
    # boot
    boot.loader.timeout = 0;
    boot.splash = {
      enable = lib.mkDefault true;
      themePackage = pkgs.plymouth-1975-theme;
      theme = "1975";
    };

    services.lnxlink.clientId = hostName;

    hardware.magic-trackpad-quirks.enable = true;

    environment.sessionVariables = lib.optionalAttrs (!config.hardware.nvidia.enabled) {
      NIXOS_OZONE_WL = "1"; # fix electron blur
    };

    boot.secureboot.enable = pkgs.stdenv.hostPlatform.isx86_64;

    # pkgs
    # virtualisation.virtualbox.host.enable = true;
    services.fwupd.enable = true;
    services.flatpak.enable = true;
    programs.direnv.enable = true;
    programs._1password.enable = true;
    programs._1password-gui.enable = true;
    services.flatpak.packages = [ "com.bambulab.BambuStudio" ];
    environment.systemPackages =
      with pkgs;
      [
        # dev
        just
        gh
        git
        neovim
        nixfmt-rfc-style
        nixd
        nixpkgs-review
        (vscode-with-extensions.override {
          vscodeExtensions =
            with vscode-marketplace;
            with vscode-extensions;
            [
              ms-dotnettools.csharp
              ms-dotnettools.vscode-dotnet-runtime
              jnoortheen.nix-ide
              ms-vsliveshare.vsliveshare
              esphome.esphome-vscode
              mkhl.direnv
              ms-vscode.cpptools
            ];
        })

        # apps
        telegram-desktop
        element-desktop
        gimp

        # shell
        wget
        p7zip
        btop
        usbutils
        pciutils
      ]
      ++ onlyArm [
        legcord
        firefox
      ]
      ++ onlyX86 [
        (microsoft-edge.override {
          commandLineArgs = [
            "--enable-features=TouchpadOverscrollHistoryNavigation,Vulkan,VaapiVideoDecoder,VaapiIgnoreDriverChecks,DefaultANGLEVulkan,VulkanFromANGLE"
            "--disable-features=GlobalShortcutsPortal" # https://issues.chromium.org/issues/404298968
          ];
        })
        discord
      ];
  };
}
