{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nix-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    apple-silicon-support = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;

      mkHost =
        system: hostname:
        let
          isDarwin = builtins.match ".*darwin$" system != null;
          builder = if isDarwin then inputs.nix-darwin.lib.darwinSystem else inputs.nixpkgs.lib.nixosSystem;
          config = builder {
            inherit system;
            specialArgs = { inherit inputs; };
            modules = [
              ./common
              ./common/${system}
              ./hosts/${system}/${hostname}
              { config._module.args = { inherit system hostname; }; }
            ];
          };
          key = if isDarwin then "darwinConfigurations" else "nixosConfigurations";
        in
        {
          ${key} = {
            ${hostname} = config;
          };
        };

      systems = builtins.attrNames (builtins.readDir ./hosts);

      hosts = builtins.concatMap (
        system:
        let
          hostnames = builtins.attrNames (builtins.readDir (./hosts + "/${system}"));
        in
        map (hostname: mkHost system hostname) hostnames
      ) systems;

    in
    builtins.foldl' lib.recursiveUpdate { } hosts;
}
