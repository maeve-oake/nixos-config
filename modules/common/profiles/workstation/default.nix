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

    services.mcpproxy-peer = {
      enable = true;
      user = config.me.username;
      settings = {
        primaryUrl = "https://mcp.lan.ci";
        listen = "127.0.0.1:3333";
      };
      path = with pkgs; [
        nodejs-slim
        nodejs-slim.npm
        go
        uv
      ];
    };

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

      # ai
      t3code

      # shell
      wget
      p7zip
      btop
      usbutils
      pciutils

      plezy
    ];
  };
}
