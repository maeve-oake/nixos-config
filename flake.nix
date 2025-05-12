{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nix-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.nixpkgs.follows = "nix-darwin";
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

    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };
  outputs =
    inputs:
    let
      commonModules = [
        ./common
        inputs.agenix.nixosModules.default
      ];

      x86_64-linux_commonModules = commonModules ++ [
        ./common/x86_64-linux
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.nix-index-database.nixosModules.nix-index
      ];

      x86_64-linux_unstableNixpkgs = {
        unstable = import inputs.nix-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };

      aarch64-darwin_commonModules = commonModules ++ [
        ./common/aarch64-darwin
        inputs.nix-homebrew.darwinModules.nix-homebrew
      ];
    in
    {
      nixosConfigurations = {
        aluminium = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = x86_64-linux_commonModules ++ [
            ./hosts/aluminium/configuration.nix
          ];
          specialArgs = x86_64-linux_unstableNixpkgs;
        };

        replika = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = x86_64-linux_commonModules ++ [
            ./hosts/replika/configuration.nix
            inputs.nix-flatpak.nixosModules.nix-flatpak
          ];
          specialArgs = x86_64-linux_unstableNixpkgs;
        };

        elster = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = x86_64-linux_commonModules ++ [
            ./hosts/elster/configuration.nix
          ];
          specialArgs = x86_64-linux_unstableNixpkgs;
        };
      };

      darwinConfigurations = {
        stainless = inputs.nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = aarch64-darwin_commonModules ++ [
            ./hosts/stainless/configuration.nix
          ];
        };
      };
    };
}
