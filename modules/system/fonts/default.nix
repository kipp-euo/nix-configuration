{ config, pkgs, ... }:
{
	fonts.enableDefaultPackages = true;
	fonts.fontDir.enable = true;
	fonts.fontconfig.useEmbeddedBitmaps = true;
}
