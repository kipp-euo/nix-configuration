{ config, pkgs, ... }:
{
	programs.rofi = {
		enable = true;
		plugins = with pkgs; [
			rofi-bluetooth
			rofi-network-manager
			rofi-emoji
			rofi-nerdy
		];
		cycle = true;
		font = "JetBrainsMono Nerd Font 12";
		location = "center";
		modes = [
			"drun"
			"run"
			"emoji"
			"nerdy"
		];
		extraConfig = {
			show-icons = true;
			case-sensitive = false;
			sidebar-mode = true;
			hover-select = true;
			tokenize = true;
			scroll-method = 0;
			window-thumbnail = true;
			me-select-entry = "";
			me-accept-entry = "MousePrimary";
			timeout = {
					action = "kb-cancel";
					delay = 0;
			};
			filebrowser = {
					directories-first = true;
					sorting-method = "name";
			};
		};
		theme = ./theme.rasi;
	};
	home.packages = with pkgs; [
		rofi-bluetooth
		rofi-network-manager
	];
}
