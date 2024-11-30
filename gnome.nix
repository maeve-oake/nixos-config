{ config, pkgs, ... }:

{
	services.xserver.desktopManager.gnome.enable = true;
	services.xserver.displayManager.gdm.enable = true;
	services.xserver.enable = true;
	
	services.xserver.desktopManager.gnome = {
		extraGSettingsOverrides = ''
			[org.gnome.shell]
			favorite-apps=['microsoft-edge.desktop', 'org.gnome.Console.desktop', 'code.desktop']
		'';

		extraGSettingsOverridePackages = [
			pkgs.gnome.gnome-shell
		];
	};
}
