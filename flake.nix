{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, lanzaboote, ... }: {
    nixosConfigurations = {
      aluminium = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/aluminium/configuration.nix

          lanzaboote.nixosModules.lanzaboote
        ];
      };
      replika = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/replika/configuration.nix
        ];
      };
    };
  };
}
