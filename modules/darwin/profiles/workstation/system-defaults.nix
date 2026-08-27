{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.profiles.workstation.enable {
    system.defaults = {
      dock = {
        orientation = "left";
        magnification = false;
        show-recents = false;
        wvous-br-corner = 1; # bottom right hot corner - do nothing
        persistent-apps = [
          "/System/Applications/Calendar.app"
          "/Applications/Microsoft Edge.app"
          "/Applications/Microsoft Outlook.app"
          "/Applications/Microsoft Teams.app"
          "/Applications/Telegram.app"
          "/Applications/Discord.app"
          "/System/Applications/Messages.app"
          "/Applications/1Password.app"
          "/Applications/Nix Apps/Visual Studio Code.app"
          "/System/Applications/Utilities/Terminal.app"
          "/System/Applications/Utilities/Activity Monitor.app"
        ];
      };
    };
  };
}
