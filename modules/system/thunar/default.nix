{ pkgs, ... }:
{
	# TODO: Put more configuration in here
	# TODO: Make xarchiver work
	programs.thunar = {
		enable = true;
		plugins = with pkgs; [
			thunar-archive-plugin
			thunar-volman
			thunar-media-tags-plugin
		];
	};
	services.tumbler.enable = true;
	services.gvfs.enable = true;
	services.udisks2.enable = true;
	programs.dconf.enable = true;
	programs.xfconf.enable = true;
	environment.systemPackages = with pkgs; [
		# xarchiver
		file-roller
		p7zip
		unzip
		unrar
	];
}
