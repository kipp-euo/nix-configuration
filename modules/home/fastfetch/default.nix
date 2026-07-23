{ config, pkgs, ... }:
{
	# TODO: Migrate config
	programs.fastfetch.enable = true;
	xdg.configFile."fastfetch".source = ./config;
}
