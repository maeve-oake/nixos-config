final: prev: {
  gnome = prev.gnome.overrideScope (gfinal: gprev: {
    mutter = gprev.mutter.overrideAttrs (oldAttrs: {
      patches = oldAttrs.patches ++ [
        (prev.fetchpatch {
          url = "https://gitlab.gnome.org/craigcabrey/mutter/-/commit/8e2168766d9e1f146d174e859f04c94f5b0cb292.patch";
          hash = "";
        })
      ];
    });
  });
}
