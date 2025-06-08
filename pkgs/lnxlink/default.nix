{
  lib,
  python3Packages,
  fetchPypi,
  wrapGAppsHook4,
  addons ? [ ],
  addAddonsRuntimeDeps ? true,
  # used by a bunch of addons
  coreutils,
  gnugrep,
  gawk,
  psmisc,
  gnused,
  # optional, used only when specified via `addons` argument
  bluez,
  xrandr,
  # ,  gsettings # XXX where?
  xset,
  # , zenity # not in 24.05, only in master
  vlc,
  pulseaudio,
  xdotool,
  wirelesstools,
}@inputs:
let
  minimalPythonDeps = [ "dasbus" ];
  minimalRuntimeDeps = [
    "coreutils"
    "gnugrep"
    "gawk"
    "psmisc"
    "gnused"
  ];

  haveMinimalPythonDeps =
    {
      pythonDeps ? [ ],
      ...
    }:
    builtins.all (d: builtins.elem d minimalPythonDeps) pythonDeps;
  haveMinimalRuntimeDeps =
    {
      runtimeDeps ? [ ],
      ...
    }:
    builtins.all (d: builtins.elem d minimalRuntimeDeps) runtimeDeps;

  canEnableByDefault =
    {
      broken ? false,
      variants ? { },
      systemDeps ? [ ],
      ...
    }@meta:
    !broken
    && builtins.length systemDeps == 0
    && builtins.length (builtins.attrNames variants) == 0
    && haveMinimalPythonDeps meta
    && haveMinimalRuntimeDeps meta;

  addonsMeta = builtins.mapAttrs (nm: meta: meta // { default = canEnableByDefault meta; }) {
    "active_window" = {
      pythonDeps = [
        "ewmh"
        "python-xlib"
      ];
    };
    "audio_select" = {
      pythonDeps = [ "pulsectl" ];
    };
    "bash" = { };
    "battery" = {
      pythonDeps = [ "dasbus" ];
    };
    "bluetooth" = {
      runtimeDeps = [ "bluez" ];
    };
    "boot_select" = {
      systemDeps = [ "grub2" ]; # grub2_efi grub2_xen
    };
    "brightness" = {
      runtimeDeps = [ "xrandr" ];
    };
    "camera_used" = {
      runtimeDeps = [ "psmisc" ];
    };
    "cpu" = {
      runtimeDeps = [
        "gnugrep"
        "gawk"
        "coreutils"
      ];
    };
    "disk_io" = { };
    "disk_usage" = { };
    "display_env" = {
      runtimeDeps = [
        "gnused"
        "coreutils"
      ];
    };
    "docker" = {
      pythonDeps = [ "docker" ];
    };
    "fullscreen" = {
      pythonDeps = [
        "ewmh"
        "python-xlib"
      ];
    };
    "gamepad" = {
      runtimeDeps = [
        "coreutils"
        "gnugrep"
      ];
    };
    "gpio" = {
      pythonDeps = [ "rpi-gpio" ];
    };
    "gpu" = {
      variants = {
        amd = {
          missingPythonDeps = [
            "pyamdgpuinfo" # XXX not in nixpkgs
          ];
          broken = true;
        };
        nvidia = {
          missingPythonDeps = [
            "nvitop" # XXX standalone python app, can I use it as a dep?
            "nvsmi" # XXX not in nixpkgs
          ];
          systemDeps = [ "nvidia-settings" ];
          broken = true;
        };
      };
    };
    "idle" = {
      broken = true;
      missingPythonDeps = [ "dbus-idle" ];
    };
    "inference_time" = { };
    "interfaces" = { };
    "ir_remote" = {
      missingPythonDeps = [
        "pigpio" # XXX not in nixpkgs
      ];
      broken = true;
    };
    "keep_alive" = {
      runtimeDeps = [
        "gsettings"
        "xset"
      ];
    };
    "keyboard_hotkeys" = {
      pythonDeps = [ "xlib-hotkeys" ];
      runtimeDeps = [ "zenity" ];
    };
    "media" = {
      broken = true;
      pythonDeps = [
        "pyalsaudio"
      ];
      missingPythonDeps = [
        "dbus-mediaplayer"
      ];
      runtimeDeps = [ "vlc" ];
    };
    "memory" = { };
    "microphone_used" = {
      runtimeDeps = [ "pulseaudio" ];
    };
    "mounts" = {
      pythonDeps = [ "pygobject3" ];
      runtimeDeps = [ "coreutils" ];
    };
    "mouse" = {
      runtimeDeps = [ "xdotool" ];
    };
    "network" = { };
    "notify" = {
      broken = true;
      missingPythonDeps = [ "dbus-notification" ];
    };
    "power_profile" = {
      systemDeps = [ "powerprofilesctl" ];
    };
    "required_restart" = { };
    "restart" = {
      pythonDeps = [ "dasbus" ];
      systemDeps = [ "systemd" ];
    };
    "restful" = {
      pythonDeps = [
        "flask"
        "waitress"
      ];
    };
    "screen_onoff" = {
      runtimeDeps = [ "xset" ];
    };
    "screenshot" = {
      pythonDeps = [
        "opencv4"
        "mss"
        "numpy"
      ];
    };
    "send_keys" = {
      runtimeDeps = [ "xdotool" ];
    };
    "shutdown" = {
      pythonDeps = [ "dasbus" ];
      systemDeps = [ "systemd" ];
    };
    "speaker_used" = {
      runtimeDeps = [ "pulseaudio" ];
    };
    "speech_recognition" = {
      pythonDeps = [
        "speechrecognition"
        "pyalsaaudio"
      ];
    };
    "statistics" = { };
    "steam" = {
      pythonDeps = [ "vdf" ];
      systemDeps = [ "steam" ];
    };
    "suspend" = {
      systemDeps = [ "systemd" ];
    };
    "sys_updates" = { };
    "systemd" = {
      pythonDeps = [ "dasbus" ];
      systemDeps = [ "sudo" ];
    };
    "temperature" = { };
    "update" = {
      broken = true;
      # runtimeDeps = [ "git" ]; # but no reason to enable for nix-ified package
    };
    "webcam" = {
      pythonDeps = [ "opencv4" ];
    };
    "wifi" = {
      broken = true;
      missingPythonDeps = [ "dbus-networkdevices" ];
      runtimeDeps = [
        "coreutils"
        "wirelesstools"
      ];
    };
    "xdg_open" = {
      runtimeDeps = [ "xdg-utils" ];
    };
  };

  allAddonNames = builtins.attrNames addonsMeta; # XXX expand variants also

  getMeta =
    nm:
    let
      parts = builtins.split "#" nm;
      meta = builtins.getAttr nm addonsMeta;
    in
    if (builtins.length parts) == 1 then
      meta
    else
      builtins.getAttr (builtins.elemAt parts 2) meta.variants;

  defaultAddons = builtins.filter (nm: addonsMeta."${nm}".default) (builtins.attrNames addonsMeta);

  addonPythonDeps =
    nm:
    let
      fun =
        {
          pythonDeps ? [ ],
          ...
        }:
        pythonDeps;
    in
    fun (getMeta nm);

  addonRuntimeDeps =
    nm:
    let
      fun =
        {
          runtimeDeps ? [ ],
          ...
        }:
        runtimeDeps;
    in
    fun (getMeta nm);

  enabledAddons = defaultAddons ++ addons;
  runtimeDepsNames = builtins.concatMap addonRuntimeDeps enabledAddons;
  runtimeDepsAddons = builtins.map (lib.flip builtins.getAttr inputs) runtimeDepsNames;
  runtimeDeps = minimalRuntimeDeps ++ lib.optionals addAddonsRuntimeDeps runtimeDepsAddons;
  runtimePath = "${lib.makeBinPath runtimeDeps}:${lib.makeSearchPathOutput "bin" "sbin" runtimeDeps}";

  pythonDepsNames = builtins.concatMap addonPythonDeps enabledAddons;
  extraPythonDeps = builtins.map (lib.flip builtins.getAttr python3Packages) pythonDepsNames;
in
python3Packages.buildPythonApplication rec {
  pname = "lnxlink";
  version = "2025.6.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-3dfE03n3yaGNspx5P2Ji1PLuLMMjlPiMugBZ+wtQVfg=";
  };

  patches = [
    ./fixes.patch
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools~=68.0.0" "setuptools" \
      --replace-fail "wheel~=0.40.0" "wheel"
  '';

  nativeBuildInputs = [
    wrapGAppsHook4
    python3Packages.setuptools
    python3Packages.wheel
  ];

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
    makeWrapperArgs+=(--prefix PATH : "${runtimePath}")
  '';

  propagatedBuildInputs =
    with python3Packages;
    [
      pygobject3

      # from pyproject.toml
      pyyaml
      requests
      distro
      paho-mqtt
      psutil
      inotify

      # installed anyway by system_monitor (not addon, but a core part)
      dasbus
      jeepney
    ]
    ++ extraPythonDeps;

  meta = with lib; {
    description = "Effortlessly manage your Linux machine using MQTT.";
    homepage = "https://github.com/bkbilly/lnxlink";
    license = licenses.mit;
    mainProgram = "lnxlink";
    addons = {
      allNames = allAddonNames;
      inherit getMeta;
      # XXX variant handling?
    };
  };
}
