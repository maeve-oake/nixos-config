{
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "swap-finger-gestures-3-4";
  version = "4";
  phases = [
    "unpackPhase"
    "installPhase"
  ];

  src = fetchFromGitHub {
    owner = "maeve-oake";
    repo = "swap-finger-gestures-3-4";
    rev = "f4400b16093cd3461bcbc9fd26f73503d977f53b";
    sha256 = "sha256-XJh45M406Y3g5Zgh1tLh1H0ifG7Q12I2Z3Na7Ur4o3s=";
  };

  installPhase = ''
    mkdir -p $out/share/gnome-shell/extensions/swap-finger-gestures-3-4@icedman.github.com/
    cp -R ./* $out/share/gnome-shell/extensions/swap-finger-gestures-3-4@icedman.github.com/.
  '';
}
