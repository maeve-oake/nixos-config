{
  stdenv,
  fetchFromGitHub,
}:
let
  pname = "tailscale-gnome-qs";
  uuid = "tailscale@joaophi.github.com";
in
stdenv.mkDerivation {
  inherit pname;
  version = "1";
  phases = [
    "unpackPhase"
    "installPhase"
  ];

  src = fetchFromGitHub {
    owner = "replikas";
    repo = pname;
    rev = "d0239060f58eb26b0cc7bdf7b887140fcbbc88da";
    sha256 = "sha256-veSlAFeg1fpK4MFu62b5ot+t4z89IZXsWxLpjSAIqhk=";
  };

  installPhase = ''
    mkdir -p $out/share/gnome-shell/extensions/${uuid}/
    cp -R ./${uuid} $out/share/gnome-shell/extensions/.
  '';

  passthru = {
    extensionPortalSlug = pname;
    extensionUuid = uuid;
  };
}
