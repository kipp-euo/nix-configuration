{ config, pkgs, ... }:
{
	programs.thunar = {
		enable = true;
		plugins = with pkgs; [
			thunar-archive-plugin
			thunar-volman
			thunar-media-tags-plugin
		];
	};
	environment.systemPackages = with pkgs; [
		file-roller
		p7zip
		unzip
		unrar
	];
}
