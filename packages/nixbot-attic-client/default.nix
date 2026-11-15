{ pkgs, ... }:
pkgs.attic-client.overrideAttrs (old: {
  passthru = (old.passthru or { }) // {
    tests = (old.passthru.tests or { }) // {
      atticd = old.passthru.tests.atticd // {
        meta = (old.passthru.tests.atticd.meta or { }) // {
          platforms = pkgs.lib.platforms.linux;
        };
      };
    };
  };
  patches = (old.patches or [ ]) ++ [
    ./patches/progress.patch
    ./patches/stateless-push.patch
  ];
})
