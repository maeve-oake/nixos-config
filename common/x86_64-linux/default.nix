{ pkgs, ... }:
{
  # common configuration for x86_64 Linux machines

  imports = [
    ../. # common/default.nix
    ./localisation.nix
    ./network.nix
  ];

  # pkgs
  virtualisation.virtualbox.host.enable = true;
  services.fwupd.enable = true;
  environment.systemPackages = with pkgs; [
    # dev
    gh
    git
    neovim
    nixpkgs-fmt
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
    microsoft-edge
    telegram-desktop
    discord
    gimp
    bitwarden-desktop

    # shell
    fzf
    zoxide
    wget
    p7zip
    lolcat
    btop
  ];
}
