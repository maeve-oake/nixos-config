{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

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
      commonModules = [
        ./common
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.nix-index-database.nixosModules.nix-index
        inputs.agenix.nixosModules.default
      ];
    in
    {
      nixosConfigurations = {
        aluminium = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = commonModules ++ [
            ./hosts/aluminium/configuration.nix
          ];
        };
        replika = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = commonModules ++ [
            ./hosts/replika/configuration.nix
          ];
        };
      };
    };
}
