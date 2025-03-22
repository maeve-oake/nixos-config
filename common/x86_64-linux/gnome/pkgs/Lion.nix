{
  stdenv,
  lib,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  name = "Lion-theme";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "maeve-oake";
    repo = "Lion";
    rev = "81107453ebd35188f79fa0870fc16e2f9895ba3f";
    sha256 = "sha256-UV6QzgOtnEGqlzvgPSZjb+MdwhblvSI1YaEjIscTox8=";
  };

  installPhase = ''
    mkdir -p $out/share/themes/Lion
    cp -r * $out/share/themes/Lion/.
  '';
}
