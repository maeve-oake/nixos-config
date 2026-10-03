{
  config,
  lib,
  pkgs,
  ...
}:
let
  user = "maeve";
  uid = toString config.users.users.${user}.uid;
  steam = lib.getExe config.programs.steam.package;

  prepareSteam = pkgs.writeShellApplication {
    name = "prepare-streaming-steam";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.procps
    ];
    text = ''
      if pgrep -u "$(id -u)" -f 'SteamLaunch AppId=' >/dev/null; then
        echo "Finish the local Steam game before starting TV gaming." >&2
        exit 1
      fi

      if ! pgrep -u "$(id -u)" -x steam >/dev/null; then
        exit 0
      fi

      timeout 30 ${steam} -shutdown &
      shutdown_pid=$!
      for _ in $(seq 1 30); do
        if ! pgrep -u "$(id -u)" -x steam >/dev/null; then
          wait "$shutdown_pid" || true
          exit 0
        fi
        sleep 1
      done

      echo "Steam did not exit; close it locally and try again." >&2
      exit 1
    '';
  };
in
{
  services.moonshine = {
    enable = true;
    inherit user;
    extraPackages = [ config.programs.steam.package ];
    settings = {
      name = "Elster";
      inhibit_sleep = true;
      # Keep Moonlight's app list limited to the private Big Picture session.
      application_scanner = [ ];
      application = [
        {
          title = "Steam Big Picture";
          command = [
            steam
            "-bigpicture"
          ];
          pre_command = [ [ (lib.getExe prepareSteam) ] ];
          stdout = "journal";
          stderr = "journal";
        }
      ];
    };
  };

  systemd.services.moonshine = {
    requires = [ "user@${uid}.service" ];
    after = [ "user@${uid}.service" ];
  };

  users.users.${user}.extraGroups = [ "moonshine" ];
}
