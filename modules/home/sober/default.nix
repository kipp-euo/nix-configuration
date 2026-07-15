{ config, pkgs, ... }:
{
	xdg.desktopEntries = {
		"SoberGamescope" = {
			name = "Sober (Gamescope)";
			exec = "gamescope-wrapped flatpak run --branch=stable --arch=x86_64 --command=sober --file-forwarding org.vinegarhq.Sober -- @@u %u @@";
			icon = "roblox";
			type = "Application";
			categories = [ "Game" ];
		};
	};
}
