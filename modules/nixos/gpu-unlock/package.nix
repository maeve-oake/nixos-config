{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
  python3,
  zstd,
  kernel,
  kernelModuleMakeFlags,
}:
let
  version = "2.0.0-unstable-2026-10-28";
  src = fetchFromGitHub {
    owner = "Zagitta";
    repo = "gpu-unlock";
    rev = "7eb51bccae0a0b7e599e084d971170e9a1e82d0c";
    hash = "sha256-1KD/J1S1uyI5GGoTwQ1cU/sXeEKlG54exSvi6U+j73M=";
  };
  nvidiaSource = fetchurl {
    url = "https://download.nvidia.com/XFree86/NVIDIA-kernel-module-source/NVIDIA-kernel-module-source-610.43.03.tar.xz";
    sha256 = "7e118923c7a23edc36114d63273a46e3e04e9af98695a42203e7ac2dfe9fc1dc";
  };
  nvidiaInstaller = fetchurl {
    url = "https://download.nvidia.com/XFree86/Linux-x86_64/610.43.03/NVIDIA-Linux-x86_64-610.43.03-no-compat32.run";
    sha256 = "e084451db730a6df29d3d74f655749c4d236e3c945f7d94b5205e84318fe2f90";
  };
  firmware = stdenvNoCC.mkDerivation {
    pname = "gpu-unlock-firmware";
    inherit version src;
    nativeBuildInputs = [
      python3
      zstd
    ];
    dontConfigure = true;
    buildPhase = ''
      runHook preBuild
      mkdir nvidia-source
      tar -xf ${nvidiaSource} -C nvidia-source --strip-components=1
      python3 firmware/extract_gsp.py ${nvidiaInstaller} assets
      python3 firmware/extract_boot_assets.py nvidia-source assets
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      install -Dm644 assets/*.bin -t "$out/lib/firmware/gpu-unlock/610.43.03"
      install -Dm644 assets/NVIDIA-LICENSE firmware/NOTICE.md licenses/*.txt \
        -t "$out/share/licenses/gpu-unlock-firmware"
      runHook postInstall
    '';
    # Keep the extracted NVIDIA firmware build local to the user's builders.
    preferLocalBuild = true;
    allowSubstitutes = false;
    meta = {
      description = "Pinned NVIDIA firmware for gpu-unlock";
      homepage = "https://github.com/Zagitta/gpu-unlock";
      license = [
        lib.licenses.unfree
        lib.licenses.gpl2Only
      ];
      platforms = [ "x86_64-linux" ];
    };
  };
in
stdenv.mkDerivation {
  pname = "gpu-unlock";
  inherit version src;
  __structuredAttrs = true;
  sourceRoot = "source/kernel/gpu_unlock";
  nativeBuildInputs = kernel.moduleBuildDependencies;
  makeFlags = kernelModuleMakeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];
  installFlags = [
    "INSTALL_MOD_PATH=${placeholder "out"}"
    "INSTALL_MOD_DIR=extra"
    "INSTALL_MOD_STRIP=1"
    "DEPMOD=true"
  ];
  # Strip before signing, inside modules_install; later stripping would
  # invalidate the signature and the matching kmodigest certificate.
  dontStrip = true;
  installPhase = ''
    runHook preInstall
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M="$PWD" modules_install \
      "''${makeFlags[@]}" "''${installFlags[@]}"
    runHook postInstall
  '';
  passthru = { inherit firmware; };
  meta = {
    description = "Pre-driver NVIDIA tensor instruction issue rate unlock";
    homepage = "https://github.com/Zagitta/gpu-unlock";
    license = lib.licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
  };
}
