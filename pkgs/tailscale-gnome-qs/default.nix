{
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "tailscale-gnome-qs";
  version = "1";
  phases = [
    "unpackPhase"
    "installPhase"
  ];

  src = fetchFromGitHub {
    owner = "replikas";
    repo = "tailscale-gnome-qs";
    rev = "d0239060f58eb26b0cc7bdf7b887140fcbbc88da";
    sha256 = "sha256-veSlAFeg1fpK4MFu62b5ot+t4z89IZXsWxLpjSAIqhk=";
  };

  installPhase = ''
    mkdir -p $out/share/gnome-shell/extensions/tailscale@joaophi.github.com/
    cp -R ./tailscale@joaophi.github.com $out/share/gnome-shell/extensions/.
  '';
}
