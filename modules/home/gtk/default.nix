{ config, pkgs, ... }:
{
	home.pointerCursor = {
		enable = true;
		gtk.enable = true;
		name = "Bibata-Modern-Ice";
		package = pkgs.bibata-cursors;
		size = 18;
	};
	gtk = {
		enable = true;
		colorScheme = "light";
		theme = {
			name = "adw-gtk3";
			package = pkgs.adw-gtk3;
		};
		font = {
			name = "JetBrainsMono Nerd Font Mono";
			size = 11;
		};
		iconTheme = {
			name = "Papirus";
			package = pkgs.papirus-icon-theme.override { color = "magenta"; };
		};
	};
}
