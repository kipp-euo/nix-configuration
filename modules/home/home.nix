{ config, pkgs, ... }:
{
	imports = [
		./bash
		./btop
		./fastfetch
		./firefox
		./foot
		./hypr
		./mako
		./mpv
		./nvim
		./prismlauncher
		./rofi
		./thunar
		./vesktop
		./waybar
	];
	programs.home-manager.enable = true;
	home = {
		username = "kipp";
		homeDirectory = "/home/kipp";
		stateVersion = "26.05"; 
		packages = with pkgs; [];
	};
}
