{
  pkgs,
  inputs,
  hostname,
  ...
}:
let
  unstable = import inputs.nix-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
  inherit (pkgs.stdenv.hostPlatform) isAarch64 isx86_64;
in
{
  # common configuration for x86_64 Linux machines

  imports = [
    ./1password.nix
    ./gnome.nix
    ./isight.nix
    ./lnxlink.nix
    ./localisation.nix
    ./magic-trackpad.nix
    ./network.nix
    ./samba.nix
    ./secureboot.nix
    ./splash.nix
    ./user.nix
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nix-flatpak.nixosModules.nix-flatpak
  ];

  # boot
  boot.loader.timeout = 0;

  services.lnxlink.clientId = hostname;

  # auto gc
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # pkgs
  _module.args.unstable = unstable;
  # virtualisation.virtualbox.host.enable = true;
  services.fwupd.enable = true;
  services.flatpak.enable = true;
  programs.direnv.enable = true;
  services.flatpak.packages = [ "com.bambulab.BambuStudio" ];
  environment.systemPackages =
    with pkgs;
    [
      # dev
      gh
      git
      neovim
      nixfmt-rfc-style
      nixd
      nixpkgs-review
      dotnet-sdk
      dotnet-runtime
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
          ];
      })

      # apps
      telegram-desktop
      element-desktop
      gimp

      # shell
      fzf
      zoxide
      wget
      p7zip
      btop
      usbutils
      pciutils
    ]
    ++ lib.optionals isAarch64 [
      legcord
      firefox
    ]
    ++ lib.optionals isx86_64 [
      (microsoft-edge.override {
        commandLineArgs = [
          "--enable-features=TouchpadOverscrollHistoryNavigation,Vulkan,VaapiVideoDecoder,VaapiIgnoreDriverChecks,DefaultANGLEVulkan,VulkanFromANGLE"
        ];
      })
      discord
    ];
}
