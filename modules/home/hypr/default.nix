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
	xdg.configFile."hypr".source = ./config;
}
