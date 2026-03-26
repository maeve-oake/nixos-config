{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.profiles.workstation.enable {

    system.defaults = {
      NSGlobalDomain = {
        NSAutomaticInlinePredictionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticCapitalizationEnabled = false;
        NSDocumentSaveNewDocumentsToCloud = false;
      };

      CustomUserPreferences = {
        "com.apple.menuextra.clock" = {
          ShowSeconds = true;
        };

        "com.apple.WindowManager" = {
          EnableStandardClickToShowDesktop = false;
        };

        "com.apple.Terminal" = {
          FocusFollowsMouse = true;
        };

        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on USB or network volumes
          DSDontWriteUSBStores = true;
          DSDontWriteNetworkStores = true;
        };

        "com.apple.AdLib" = {
          # Disable personalized advertising
          forceLimitAdTracking = true;
          allowApplePersonalizedAdvertising = false;
          allowIdentifierForAdvertising = false;
        };
      };

      CustomSystemPreferences = {
        "com.apple.CoreBrightness"."DisplayPreferences"."37D8832A-2D66-02CA-B9F7-8F30A301B230" = {
          AutoBrightnessEnable = false;
        };
      };

      LaunchServices.LSQuarantine = false; # do not quarantine downloaded applications

      finder = {
        AppleShowAllFiles = true; # show hidden files
        AppleShowAllExtensions = true; # show all extensions
        NewWindowTarget = "Computer"; # default finder location
        _FXSortFoldersFirst = false; # don't sort folders seperately
        FXEnableExtensionChangeWarning = false; # don't warn on extension change
        FXDefaultSearchScope = "SCcf"; # search in This Folder by default
        ShowPathbar = true; # show pathbar at the bottom of the window
        QuitMenuItem = true; # allow quit
      };

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
          "/Applications/Nix Apps/Discord.app"
          "/System/Applications/Messages.app"
          "/Applications/1Password.app"
          "/Applications/Nix Apps/Visual Studio Code.app"
          "/System/Applications/Utilities/Terminal.app"
          "/System/Applications/Utilities/Activity Monitor.app"
        ];
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

      controlcenter = {
        NowPlaying = false;
        Sound = true;
      };
    };
  };
}
