{ pkgs, ... }:
pkgs.attic-client.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ./patches/progress.patch
    ./patches/stateless-push.patch
  ];
})
