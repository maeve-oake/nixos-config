{
  config,
  ...
}:
{
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
}
