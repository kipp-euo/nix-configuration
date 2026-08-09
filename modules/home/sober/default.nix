{ ... }:
{
	# TODO: Create the desktop entry only if gamescope systemd module is active
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
