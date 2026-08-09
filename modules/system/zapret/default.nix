{ ... }:
{
	services.zapret = {
		enable = true;
		params = [
			"--dpi-desync=fake,disorder2"
			"--dpi-desync-ttl=1"
			"--dpi-desync-autottl=2"
		];
		configureFirewall = true;
		httpMode = "full";
		httpSupport = true;
		udpSupport = false;
		whitelist = [
			"youtube.com"
			"googlevideo.com"
			"ytimg.com"
			"youtu.be"
			"discord.com"
			"discord.gg"
			"discordapp.com"
			"discord.media"
			"rutracker.org"
		];
	};
}
