{ config, pkgs, ... }:
{
	fonts.enableDefaultPackages = true;
	fonts.packages = with pkgs; [
		corefonts
		liberation_ttf
		nerd-fonts.jetbrains-mono
		noto-fonts
		noto-fonts-cjk-sans
		noto-fonts-cjk-serif
		noto-fonts-color-emoji
		noto-fonts-emoji-blob-bin
		vista-fonts
	];
}
