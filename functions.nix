# credit to Wolfgang <3
# https://github.com/notthebee/nix-config/blob/main/flakeHelpers.nix

inputs:
let
  commonModules = [
    ./common
    inputs.agenix.nixosModules.default
  ];
in
{
  mkNixos = machineHostname: nixpkgsVersion: extraModules: rec {
    nixosConfigurations.${machineHostname} = nixpkgsVersion.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        unstable = import inputs.nix-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      modules =
        commonModules
        ++ extraModules
        ++ [
          ./hosts/${machineHostname}/configuration.nix
          ./common/x86_64-linux
          inputs.lanzaboote.nixosModules.lanzaboote
          inputs.nix-index-database.nixosModules.nix-index
          inputs.nix-flatpak.nixosModules.nix-flatpak
        ];
    };
  };

  mkDarwin = machineHostname: nixpkgsVersion: extraModules: {
    darwinConfigurations.${machineHostname} = nixpkgsVersion.lib.darwinSystem {
      system = "aarch64-darwin";
      modules =
        commonModules
        ++ extraModules
        ++ [
          ./hosts/${machineHostname}/configuration.nix
          ./common/aarch64-darwin
          inputs.nix-homebrew.darwinModules.nix-homebrew
        ];
    };
  };

  mkMerge = inputs.nixpkgs.lib.lists.foldl' (
    a: b: inputs.nixpkgs.lib.attrsets.recursiveUpdate a b
  ) { };
}
