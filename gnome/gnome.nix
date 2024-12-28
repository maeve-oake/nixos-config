{ config, pkgs, lib, ... }:

{
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.enable = true;

  # theme
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnomeExtensions.user-themes
    (callPackage ./Lion.nix { })
  ];

  # remove gnome tour and web browser
  environment.gnome.excludePackages = [
    pkgs.epiphany
    pkgs.gnome-tour
  ];

  # profile picture
  system.activationScripts.script.text = ''
    mkdir -p /var/lib/AccountsService/{icons,users}
    cp /home/maeve/.config/img/pfp_maeve.jpg /var/lib/AccountsService/icons/maeve
    echo -e "[User]\nIcon=/var/lib/AccountsService/icons/maeve\n" > /var/lib/AccountsService/users/maeve

    chown root:root /var/lib/AccountsService/users/maeve
    chmod 0600 /var/lib/AccountsService/users/maeve

    chown root:root /var/lib/AccountsService/icons/maeve
    chmod 0444 /var/lib/AccountsService/icons/maeve
  '';

  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        lockAll = true;
        settings = {
          # behaviour
          "org/gnome/mutter" = {
            dynamic-workspaces = true;
            experimental-features = [ "scale-monitor-framebuffer" ];
          };
          "org/gnome/desktop/wm/preferences" = {
            auto-raise = false;
            focus-mode = "sloppy";
          };

          # power & sleep
          "org/gnome/settings-daemon/plugins/power" = {
            power-button-action = "hibernate";
            sleep-inactive-battery-type = "hibernate";
          };

          # dock & extensions
          "org/gnome/shell" = {
            favorite-apps = [ "microsoft-edge.desktop" "discord.desktop" "org.telegram.desktop.desktop" "code.desktop" "org.gnome.Console.desktop" "org.gnome.Nautilus.desktop" ];
            enabled-extensions = [ "user-theme@gnome-shell-extensions.gcampax.github.com" ];
          };

          # appearance
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            enable-hot-corners = false;
            show-battery-percentage = true;
          };
          "org/gnome/shell/extensions/user-theme" = {
            name = "Lion";
          };
          "org/gnome/desktop/background" = {
            picture-uri-dark = "file:///home/maeve/.config/img/1975.jpg";
          };

          # keybinds
          "org/gnome/settings-daemon/plugins/media-keys" = {
            custom-keybindings = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" ];
            screensaver = [ "<Shift><Super>x" ];
            search = [ "<Super>space" ];
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
            binding = "<Super>Return";
            command = "kgx";
            name = "run terminal";
          };
          "org/gnome/desktop/wm/keybindings" = {
            close = [ "<Shift><Super>q" ];
            maximize = [ "<Shift><Super>Up" ];
            move-to-monitor-down = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
            move-to-monitor-left = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
            move-to-monitor-right = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
            move-to-monitor-up = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
            move-to-workspace-1 = [ "<Shift><Super>1" ];
            move-to-workspace-2 = [ "<Shift><Super>2" ];
            move-to-workspace-3 = [ "<Shift><Super>3" ];
            move-to-workspace-4 = [ "<Shift><Super>4" ];
            move-to-workspace-5 = [ "<Shift><Super>5" ];
            move-to-workspace-6 = [ "<Shift><Super>6" ];
            move-to-workspace-7 = [ "<Shift><Super>7" ];
            move-to-workspace-8 = [ "<Shift><Super>8" ];
            move-to-workspace-9 = [ "<Shift><Super>9" ];
            switch-to-workspace-1 = [ "<Super>1" ];
            switch-to-workspace-2 = [ "<Super>2" ];
            switch-to-workspace-3 = [ "<Super>3" ];
            switch-to-workspace-4 = [ "<Super>4" ];
            switch-to-workspace-5 = [ "<Super>5" ];
            switch-to-workspace-6 = [ "<Super>6" ];
            switch-to-workspace-7 = [ "<Super>7" ];
            switch-to-workspace-8 = [ "<Super>8" ];
            switch-to-workspace-9 = [ "<Super>9" ];
            move-to-workspace-left = [ "<Shift><Control><Super>Left" ];
            move-to-workspace-right = [ "<Shift><Control><Super>Right" ];
            switch-input-source = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
            switch-input-source-backward = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
            toggle-fullscreen = [ "<Super>f" ];
            unmaximize = [ "<Shift><Super>Down" ];
          };
          "org/gnome/mutter/keybindings" = {
            toggle-tiled-left = [ "<Shift><Super>Left" ];
            toggle-tiled-right = [ "<Shift><Super>Right" ];
          };
          "org/gnome/shell/keybindings" = {
            focus-active-notification = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
            switch-to-application-1 = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
            switch-to-application-2 = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
            switch-to-application-3 = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
            switch-to-application-4 = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
            toggle-application-view = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
            toggle-message-tray = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
          };
        };
      }
    ];
  };
}
