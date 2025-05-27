{
  pkgs,
  buildGoModule,
  lib,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "luzifer-streamdeck";
  version = "1.7.2";

  src =
    fetchFromGitHub {
      owner = "Luzifer";
      repo = "streamdeck";
      rev = "122bd63cc98ec304788e655f377f71e21e5117d5";
      sha256 = "sha256-qagu83Cz/cQyRAAKBCffWVyOq+pF7GtcfWIgVwiK76Q=";
    }
    + "/cmd/streamdeck";

  vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  buildInputs = with pkgs; [
    udev
  ];

  postPatch = ''
    substituteInPlace go.mod \
      --replace-fail "replace github.com/Luzifer/streamdeck => ../../" ""
  '';

  meta = {
    description = "streamdeck is a library and management tool to use an Elgato StreamDeck on a Linux system written in Go.";
    homepage = "https://github.com/Luzifer/streamdeck";
    license = lib.licenses.asl20;
  };
}
