{ config, pkgs, ... }:

{
	services.xserver.desktopManager.gnome.enable = true;
	services.xserver.displayManager.gdm.enable = true;
	services.xserver.enable = true;
	
	services.xserver.desktopManager.gnome = {
		extraGSettingsOverrides = ''
			[org.gnome.shell]
			favorite-apps=['microsoft-edge.desktop', 'discord.desktop', 'org.telegram.desktop.desktop', 'code.desktop', 'org.gnome.Console.desktop', 'org.gnome.Nautilus.desktop']
			welcome-dialog-last-shown-version='100'
			
			[org.gnome.desktop.interface]
			color-scheme='prefer-dark'
			enable-hot-corners=false
			toolkit-accessibility=false

			[org.gnome.mutter]
			dynamic-workspaces=true
			experimental-features=['scale-monitor-framebuffer']
		'';

		extraGSettingsOverridePackages = [
			pkgs.gnome.gnome-shell
			pkgs.gsettings-desktop-schemas
			pkgs.gnome.mutter
		];
	};
}
