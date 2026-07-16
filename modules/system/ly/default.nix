{ config, pkgs, ... }:
{
	services.displayManager.ly = {
		enable = true;
		x11Support = false;
	};
	services.displayManager.defaultSession = "hyprland";
}
