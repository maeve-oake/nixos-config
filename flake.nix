{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:anna-oake/nixos-hardware";

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
      # Temporary pin for the U-Boot DTC fix; return to main once merged.
      # https://github.com/nix-community/nixos-apple-silicon/pull/559
      url = "github:nix-community/nixos-apple-silicon/54795b299afbc62bc3e77a1d3526211a99e4e703";
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

    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-things = {
      url = "github:oake/nix-things";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    buildbot-nix = {
      url = "github:nix-community/buildbot-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    decider-efi = {
      url = "github:anna-oake/decider.efi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      blueprint = inputs.nix-things.lib.mkFlake {
        inherit inputs;
        nixpkgs.overlays = [
          inputs.nix-vscode-extensions.overlays.default
        ];
      };
    in
    blueprint
    // {
      agenix-rekey = inputs.agenix-rekey.configure {
        userFlake = inputs.self;
        nixosConfigurations = blueprint.nixosConfigurations // blueprint.darwinConfigurations;
        agePackage = p: p.age;
      };
    };
}
