{ config, pkgs, ... }:
{
	# TODO: Put more configuration in here
	programs.thunar = {
		enable = true;
		plugins = with pkgs; [
			thunar-archive-plugin
			thunar-volman
			thunar-media-tags-plugin
		];
	};
	services.gvfs.enable = true;
	programs.dconf.enable = true;
	programs.xfconf.enable = true;
	services.tumbler.enable = true;
	environment.systemPackages = with pkgs; [
		file-roller
		p7zip
		unzip
		unrar
	];
}
