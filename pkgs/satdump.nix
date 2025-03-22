{
  pkgs,
  stdenv,
  lib,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  name = "satdump";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "SatDump";
    repo = "SatDump";
    rev = "1.2.2";
    sha256 = "sha256-+Sne+NMwnIAs3ff64fBHAIE4/iDExIC64sXtO0LJwI0=";
  };

  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
  ];
  buildInputs = with pkgs; [
    # required deps
    fftwFloat
    libpng
    libtiff
    jemalloc
    volk
    (nng.overrideAttrs (old: {
      cmakeFlags = old.cmakeFlags ++ [ "-DBUILD_SHARED_LIBS=ON" ];
    }))
    rtl-sdr-librtlsdr
    hackrf
    airspy
    airspyhf
    glfw
    zenity
    zstd
    curl

    opencl-headers
    ocl-icd
    rocmPackages.clr.icd

    # optional hw support
    libad9361
    libiio
    # sdrplay
    # limesuite
    # libbladeRF
    # uhd
    # hdf5
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  postPatch = ''
    substituteInPlace src-core/CMakeLists.txt \
      --replace-fail '$'{CMAKE_INSTALL_PREFIX}/'$'{CMAKE_INSTALL_LIBDIR} '$'{CMAKE_INSTALL_FULL_LIBDIR}
  '';
}
