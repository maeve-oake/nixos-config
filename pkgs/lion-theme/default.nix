{
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "lion-theme";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "maeve-oake";
    repo = "Lion";
    rev = "2b790684f727f893fa2680e4144d5df4187cc0d3";
    sha256 = "sha256-AQgTzU6DRWOBch79gyuvhrYv0ZkUvZQYn1UdNRdNmkE=";
  };

  installPhase = ''
    mkdir -p $out/share/themes/Lion
    cp -r * $out/share/themes/Lion/.
  '';
}
