{ config, pkgs, ... }:
{
	programs.rofi.enable = true;
	xdg.configFile."rofi".source = ./config;
	home.packages = with pkgs; [
		rofi-bluetooth
		rofi-network-manager
	];
}
