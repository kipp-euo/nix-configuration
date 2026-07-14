{ config, pkgs, ... }:
{
	programs.fastfetch.enable = true;
	xdg.configFile."fastfetch".source = ./config;
}
