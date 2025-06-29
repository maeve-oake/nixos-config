{
  stdenvNoCC,
  fetchgit,
  lib,
}:

stdenvNoCC.mkDerivation {
  pname = "plymouth-1975-theme";
  version = "1.0.0";

  src = fetchgit {
    url = "https://github.com/maeve-oake/plymouth-1975-theme";
    sha256 = "sha256-OT4GwqDwQgF0kVMKPN0kSQoRHAuTAcvA1nh4PTGBaK8=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plymouth/themes/1975
    cp * $out/share/plymouth/themes/1975
    find $out/share/plymouth/themes/ -name \*.plymouth -exec sed -i "s@\/usr\/@$out\/@" {} \;

    runHook postInstall
  '';

  meta = {
    description = "The 1975 Plymouth boot splash";
    platforms = lib.platforms.linux;
  };
}
