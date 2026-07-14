{ config, pkgs, ... }:
{
	services.mako.enable = true;
	xdg.configFile."mako".source = ./config;
}
