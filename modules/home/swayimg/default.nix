{ config, pkgs, ... }:
{
	programs.swayimg = {
		enable = true;
	};
	xdg.configFile."swayimg".source = ./config;
}
