final: prev: {
  mutter = prev.mutter.overrideAttrs (old: {
    patches = old.patches ++ [
      (prev.fetchpatch {
        url = "https://gitlab.gnome.org/craigcabrey/mutter/-/commit/8e2168766d9e1f146d174e859f04c94f5b0cb292.patch";
        hash = "sha256-BeKMTBDkE5uPJYMb4VCE7wsNCie+OdraPt8LbJVkg3k=";
      })
    ];
  });
}
