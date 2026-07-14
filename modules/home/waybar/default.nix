{ config, pkgs, ... }:
{
	programs.waybar = {
		enable = true;
		systemd = {
			enable = true;
			targets = [
				"hyprland-session.target"
				"graphical-session.target"
			];
		};
	};
	xdg.configFile."waybar".source = ./config;
}
