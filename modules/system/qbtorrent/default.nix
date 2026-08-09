{ ... }:
{
	services.qbittorrent = {
		enable = true;
		openFirewall = true; # Opens WebUI and torrenting ports
		user = "qbittorrent";
		group = "qbittorrent";
	};

	users.users.qbittorrent = {
		isSystemUser = true;
		group = "qbittorrent";
	};
	users.groups.qbittorrent = {};
}
