{ config, pkgs, ... }:
{
	fonts.enableDefaultPackages = true;
	fonts.packages = with pkgs; [
		corefonts
		vista-fonts
		noto-fonts
		noto-fonts-cjk-sans
		noto-fonts-cjk-serif
		noto-fonts-color-emoji
		noto-fonts-emoji-blob-bin
		liberation_ttf
		nerd-fonts.jetbrains-mono
	];
}
