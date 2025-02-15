{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "tailscale-gnome-qs";
  version = "v1";
  phases = [ "unpackPhase" "installPhase" ];

  src = fetchFromGitHub {
    owner = "replikas";
    repo = "tailscale-gnome-qs";
    rev = "e618b4731fedf895ad33cbf97909ea5079e1b27a";
    sha256 = "sha256-1IOKOPC1riWYruEZOHy17GQDY+XQ1jy6fKdpXY5RXAw=";
  };

  installPhase = ''
    mkdir -p $out/share/gnome-shell/extensions/tailscale@joaophi.github.com/
    cp -R ./tailscale@joaophi.github.com $out/share/gnome-shell/extensions/.
  '';
}
