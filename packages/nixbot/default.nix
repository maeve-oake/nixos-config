{ inputs, pkgs, ... }:
let
  upstream = inputs.nixbot;
  evaluator = pkgs.callPackage "${upstream}/packages/nix-eval-jobs.nix" { };
  package = pkgs.python3.pkgs.callPackage "${upstream}/packages/nixbot.nix" {
    nix-eval-jobs = evaluator;
  };
in
package.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ./patches/persistent-finalization-schema.patch
    ./patches/revision-identity.patch
    ./patches/shared-publications.patch
    ./patches/awaited-lifecycle.patch
    ./patches/build-finished-context.patch
    ./patches/native-upload-ui.patch
    ./patches/live-log-state.patch
  ];
})
