{ config, pkgs, ... }:
{
	imports = [
		# ./vesktop
		./bash
		./btop
		./development
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
			bc
			libjxl
		];
	};
}
