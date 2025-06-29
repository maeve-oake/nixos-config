{
  stdenvNoCC,
  fetchgit,
  lib,
}:

stdenvNoCC.mkDerivation {
  pname = "plymouth-1975-theme";
  version = "1.0.0";

  src = fetchgit {
    url = "https://github.com/maeve-oake/cfg";
    sparseCheckout = [
      "plymouth/1975"
    ];
    sha256 = "sha256-zgTVX07PdfGcVmdrPEcOe/l7e6dAevcZtmDyUJfR6VM=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plymouth/themes/1975
    cp plymouth/1975/* $out/share/plymouth/themes/1975
    find $out/share/plymouth/themes/ -name \*.plymouth -exec sed -i "s@\/usr\/@$out\/@" {} \;

    runHook postInstall
  '';

  meta = {
    description = "Plymouth theme with The 1975 graphics";
    platforms = lib.platforms.linux;
  };
}
