{ config, pkgs, ... }:

{
	services.xserver.desktopManager.gnome.enable = true;
	services.xserver.displayManager.gdm.enable = true;
	services.xserver.enable = true;
	
	services.xserver.desktopManager.gnome = {
		extraGSettingsOverrides = ''
			# power & sleep
			[org.gnome.settings-daemon.plugins.power]
			power-button-action='hibernate'
			sleep-inactive-battery-type='hibernate'

			[org.gnome.shell]
			favorite-apps=['microsoft-edge.desktop', 'discord.desktop', 'org.telegram.desktop.desktop', 'code.desktop', 'org.gnome.Console.desktop', 'org.gnome.Nautilus.desktop']
		        welcome-dialog-last-shown-version='100'
			# ^^ never show tour

			[org.gnome.desktop.interface]
			color-scheme='prefer-dark'
			enable-hot-corners=false
			toolkit-accessibility=false
			show-battery-percentage=true

			[org.gnome.mutter]
			dynamic-workspaces=true
			experimental-features=['scale-monitor-framebuffer']

			[org.gnome.desktop.wm.preferences]
			auto-raise=false
			focus-mode='sloppy'

			[org.gnome.desktop.background]
			picture-uri='file:///home/maeve/.config/img/1975.jpg'

			# keybinds

			[org.gnome.settings-daemon.plugins.media-keys]
			custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings.custom0/']
			help=@as []
			screensaver=['<Shift><Super>x']
			search=['<Super>space']

			[org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom0]
			binding='<Super>Return'
			command='kgx'
			name='terminal'

			[org.gnome.desktop.wm.keybindings]
			close=['<Shift><Super>q']
			maximize=['<Shift><Super>Up']
			move-to-monitor-down=@as []
			move-to-monitor-left=@as []
			move-to-monitor-right=@as []
			move-to-monitor-up=@as []
			move-to-workspace-1=['<Shift><Super>1']
			move-to-workspace-2=['<Shift><Super>2']
			move-to-workspace-3=['<Shift><Super>3']
			move-to-workspace-4=['<Shift><Super>4']
			move-to-workspace-5=['<Shift><Super>5']
			move-to-workspace-6=['<Shift><Super>6']
			move-to-workspace-7=['<Shift><Super>7']
			move-to-workspace-8=['<Shift><Super>8']
			move-to-workspace-9=['<Shift><Super>9']
			move-to-workspace-left=['<Shift><Control><Super>Left']
			move-to-workspace-right=['<Shift><Control><Super>Right']
			switch-input-source=@as []
			switch-input-source-backward=@as []
			switch-to-workspace-1=['<Super>1']
			switch-to-workspace-2=['<Super>2']
			switch-to-workspace-3=['<Super>3']
			switch-to-workspace-4=['<Super>4']
			switch-to-workspace-5=['<Super>5']
			switch-to-workspace-6=['<Super>6']
			switch-to-workspace-7=['<Super>7']
			switch-to-workspace-8=['<Super>8']
			switch-to-workspace-9=['<Super>9']
			toggle-fullscreen=['<Super>f']
			unmaximize=['<Shift><Super>Down']

			[org.gnome.mutter.keybindings]
			toggle-tiled-left=['<Shift><Super>Left']
			toggle-tiled-right=['<Shift><Super>Right']

			[org.gnome.shell.keybindings]
			focus-active-notification=@as []
			switch-to-application-1=@as []
			switch-to-application-2=@as []
			switch-to-application-3=@as []
			switch-to-application-4=@as []
			toggle-application-view=@as []
			toggle-message-tray=@as []

		'';

		extraGSettingsOverridePackages = [
			pkgs.gnome.gnome-shell
			pkgs.gsettings-desktop-schemas
			pkgs.gnome.mutter
			pkgs.gnome.gnome-settings-daemon
		];
	};
}
