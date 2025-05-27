{
  pkgs,
  inputs,
  system,
  hostname,
  ...
}:
let
  unstable = import inputs.nix-unstable {
    inherit system;
    config.allowUnfree = true;
  };
  nixpkgs-24-11 = import inputs.nixpkgs-24-11 {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  # common configuration for x86_64 Linux machines

  imports = [
    ./localisation.nix
    ./network.nix
    ./user.nix
    ./1password.nix
    ./isight.nix
    ./gnome
    ./lnxlink.nix
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nix-flatpak.nixosModules.nix-flatpak
  ];

  # boot
  boot.loader.timeout = 0;

  _module.args.unstable = unstable;
  _module.args.nixpkgs-24-11 = nixpkgs-24-11;

  services.lnxlink.clientId = hostname;

  # pkgs
  virtualisation.virtualbox.host.enable = true;
  services.fwupd.enable = true;
  services.flatpak.enable = true;
  services.flatpak.packages = [ "com.bambulab.BambuStudio" ];
  environment.systemPackages = with pkgs; [
    # dev
    gh
    git
    neovim
    nixfmt-rfc-style
    nixd
    dotnet-sdk
    dotnet-runtime
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        ms-dotnettools.csharp
        ms-dotnettools.vscode-dotnet-runtime
        jnoortheen.nix-ide
        ms-vsliveshare.vsliveshare
      ];
    })

    # apps
    (nixpkgs-24-11.microsoft-edge.override {
      commandLineArgs = [ "--enable-features=TouchpadOverscrollHistoryNavigation,Vulkan" ];
    })
    telegram-desktop
    element-desktop
    discord
    gimp

    # shell
    fzf
    zoxide
    wget
    p7zip
    btop
    usbutils
    pciutils
  ];
}
