{ config, pkgs, ... }:
{
	imports = [
		# ./vesktop
		# ./mime
		./bash
		./btop
		./development
		./fastfetch
		./firefox
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
