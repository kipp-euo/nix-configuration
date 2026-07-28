{ config, pkgs, ... }:
{
	imports = [
		# ./mime
		# ./vesktop
		./bash
		./btop
		./development
		./fastfetch
		./firefox
		./fonts
		./foot
		./gtk
		./hypr
		./libreoffice
		./mako
		./mpv
		./nvim
		./prismlauncher
		./qt
		./rofi
		./sober
		./swappy
		./swayimg
		./thunar
		./waybar
	];
	programs.home-manager.enable = true;
	home = {
		username = "kipp";
		homeDirectory = "/home/kipp";
		stateVersion = "26.05"; 
		packages = with pkgs; [
			kdePackages.kolourpaint
			audacious
			audacity
			bc
			libjxl
		];
	};
}
