{ config, pkgs, ... }: {
	wayland.windowManager.hyprland = {
		enable = true;
		package = null;
		portalPackage = null;
		systemd.variables = [ "--all" ];
	};
	home.packages = with pkgs; [
		hyprpaper
		hyprpicker
		grim
		slurp
		wf-recorder
		swappy
		wl-clipboard
		cliphist
	];
	xdg.portal.config.common.default = [
		"hyprland"
		"gtk"
	];
	xdg.configFile."hypr".source = ./config;
}
