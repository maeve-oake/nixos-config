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
    owner = "oake";
    repo = pname;
    rev = "0e5294c9a7b376b32490e5b134e9abe51418b7fd";
    sha256 = "sha256-3kkHR/c1lMMILtXa6JVwalwp+HTeLiwxClldjBU6i7Y=";
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
