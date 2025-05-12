{ pkgs, ... }:
{
  # common configuration for x86_64 Linux machines

  imports = [
    ./localisation.nix
    ./network.nix
    ./user.nix
    ./1password.nix
  ];

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
    (microsoft-edge.override {
      commandLineArgs = [ "--enable-features=TouchpadOverscrollHistoryNavigation" ];
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
  ];
}
