{
  config,
  lib,
  ...
}:
{
  # TODO: possibly create a nice dock setup and apply it? the mess with GUIDs doesnt look great

  config = lib.mkIf config.profiles.workstation.enable {

    system.defaults = {
      CustomUserPreferences = {
        "com.apple.menuextra.clock" = {
          ShowSeconds = true;
        };

        "com.apple.Terminal" = {
          FocusFollowsMouse = true;
        };
      };

      LaunchServices.LSQuarantine = false; # do not quarantine downloaded applications

      finder = {
        AppleShowAllFiles = true; # show hidden files
        NewWindowTarget = "Computer"; # default finder location
        ShowPathbar = true; # show pathbar at the bottom of the window
        QuitMenuItem = true; # allow quit
      };

      dock = {
        orientation = "left";
        magnification = true;
        show-recents = false;
      };

      loginwindow = {
        LoginwindowText = config.me.email;
      };

      WindowManager = {
        EnableTiledWindowMargins = false;
        EnableTilingByEdgeDrag = true;
      };

      trackpad = {
        Clicking = true; # tap-to-click
        TrackpadThreeFingerDrag = true;
      };
    };
  };
}
