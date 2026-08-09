{ ... }:
{
	programs.waybar = {
		enable = true;
		systemd = {
			enable = true;
		};
	};
	xdg.configFile."waybar".source = ./config;
}
