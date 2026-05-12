{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./fish.nix
  ];

  config = lib.mkIf config.profiles.workstation.enable {
    programs.direnv.enable = true;
    programs._1password.enable = true;
    programs._1password-gui.enable = true;

    environment.systemPackages = with pkgs; [
      # dev
      just
      gh
      git
      neovim
      nixfmt
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

      # shell
      wget
      p7zip
      btop
      usbutils
      pciutils
    ];
  };
}
