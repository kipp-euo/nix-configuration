{ config, pkgs, ... }:
{
	xdg.configFile."Thunar".source = ./config;
}
