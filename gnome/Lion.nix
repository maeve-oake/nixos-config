{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "Lion-theme";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "maeve-oake";
    repo = "Lion";
    rev = "360384c6f4806b84e2c593edb27d240a6b824789";
    sha256 = "sha256-n6r5oOuxjY86TLD4YM51rENHUR4qfzvlf4D3hZHpkyM=";
  };

  installPhase = ''
    mkdir -p $out/share/themes/Lion
    cp -r * $out/share/themes/Lion/.
  '';
}
