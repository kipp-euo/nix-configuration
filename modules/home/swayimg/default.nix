{ ... }:
{
	# TODO: Migrate config
	programs.swayimg = {
		enable = true;
	};
	xdg.mimeApps.defaultApplications."image/*" = [ "swayimg.desktop" ];
	xdg.configFile."swayimg".source = ./config;
}
