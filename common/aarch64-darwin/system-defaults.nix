{ ... }:
{
  system.defaults = {
    CustomUserPreferences = {
      "com.apple.menuextra.clock" = {
        ShowSeconds = true;
      };
    };

    dock = {
      autohide = true;
      autohide-delay = 0.0;
      largesize = 72; # magnification size
      tilesize = 28; # unmagnified size
      orientation = "left";
      magnification = true;
      show-recents = false;
    };
  };
}