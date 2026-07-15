{ config, pkgs, ... }:
{
	qt.enable = true;
	qt.platformTheme.name = "gtk3";
	home.sessionVariables = {
		QT_USE_PORTAL = "1";
	};
}
