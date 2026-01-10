{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";

    blueprint = {
      url = "github:numtide/blueprint";
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
      url = "github:nix-community/nixos-apple-silicon/main";
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
      inputs.nix-unstable.follows = "nix-unstable";
    };

    buildbot-nix = {
      url = "github:nix-community/buildbot-nix";
      inputs.nixpkgs.follows = "nix-unstable";
    };
  };

  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;
      inherit (inputs.nix-things.lib)
        mkDiskoChecks
        mkDeployNodes
        mkBootstrapScripts
        mkLxcScripts
        ;

      blueprint = inputs.blueprint {
        inherit inputs;
        nixpkgs.config.allowUnfree = true;
      };

      mkModules =
        modules:
        modules
        // {
          default = {
            imports = lib.attrsets.attrValues modules;
          };
        };
      bootstrapScripts = mkBootstrapScripts blueprint.nixosConfigurations;
      lxcScripts = mkLxcScripts blueprint.nixosConfigurations;
      deployCfgs = mkDeployNodes blueprint.nixosConfigurations;
    in
    {
      inherit (blueprint)
        nixosConfigurations
        darwinConfigurations
        ;

      commonModules = mkModules blueprint.modules.common;
      nixosModules = mkModules blueprint.nixosModules;
      darwinModules = mkModules blueprint.darwinModules;

      checks = lib.foldl' lib.recursiveUpdate blueprint.checks [
        (mkDiskoChecks blueprint.nixosConfigurations)
        bootstrapScripts.checks
        lxcScripts.checks
        deployCfgs.checks
      ];

      apps = lib.foldl' lib.recursiveUpdate bootstrapScripts.apps [
        lxcScripts.apps
      ];

      deploy.nodes = deployCfgs.nodes;

      agenix-rekey = inputs.agenix-rekey.configure {
        userFlake = inputs.self;
        nixosConfigurations = blueprint.nixosConfigurations // blueprint.darwinConfigurations;
      };
    };
}
