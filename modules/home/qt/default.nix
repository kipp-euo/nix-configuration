{ config, pkgs, ... }:
{
	qt.enable = true;
	qt.platformTheme.name = "gtk";
	home.sessionVariables = {
		QT_USE_PORTAL = "1";
	};
}
