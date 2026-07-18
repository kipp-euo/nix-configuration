{ config, pkgs, ... }:
{
	imports = [
		./bash
		./btop
		./fastfetch
		./firefox
		./foot
		./gtk
		./hypr
		./mako
		./mpv
		./nvim
		./prismlauncher
		./qt
		./rofi
		./sober
		./swayimg
		./thunar
		# ./vesktop
		./waybar
	];
	programs.home-manager.enable = true;
	home = {
		username = "kipp";
		homeDirectory = "/home/kipp";
		stateVersion = "26.05"; 
		packages = with pkgs; [
			kdePackages.kolourpaint
			bc
			libjxl
		];
	};
}
