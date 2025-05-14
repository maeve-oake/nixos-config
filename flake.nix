{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nix-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

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
  };
  outputs =
    inputs:
    let
      inherit (import ./functions.nix inputs) mkNixos mkDarwin mkMerge;
    in
    mkMerge [
      (mkNixos "aluminium" inputs.nixpkgs [ ])
      (mkNixos "replika" inputs.nixpkgs [ ])
      (mkNixos "elster" inputs.nixpkgs [ ])
      (mkDarwin "stainless" inputs.nix-darwin [ ])
    ];
}
