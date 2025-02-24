{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
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
  };
  outputs = inputs:
    let
      x86_64-linux_commonModules = [
        ./common/x86_64-linux
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.nix-index-database.nixosModules.nix-index
        inputs.agenix.nixosModules.default
      ];

      aarch64-darwin_commonModules = [
        ./common/aarch64-darwin
      ];
    in
    {
      nixosConfigurations = {
        aluminium = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = x86_64-linux_commonModules ++ [
            ./hosts/aluminium/configuration.nix
          ];
        };
        replika = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = x86_64-linux_commonModules ++ [
            ./hosts/replika/configuration.nix
          ];
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
