{ config, pkgs, ... }:
{
	fonts.enableDefaultPackages = true;
	fonts.packages = with pkgs; [
		corefonts
		liberation_ttf
		nerd-fonts.jetbrains-mono
		noto-fonts
		noto-fonts-cjk-sans
		noto-fonts-color-emoji
		noto-fonts-emoji-blob-bin
		vista-fonts
		wqy_zenhei
	];
	fonts.fontconfig.defaultFonts = {
		serif = [
			"JetBrainsMono Nerd Font"
			"Noto Sans Mono CJK"
			"WenQuanYi Zen Hei Mono"
		];
		sansSerif = [
			"JetBrainsMono Nerd Font"
			"Noto Sans Mono CJK"
			"WenQuanYi Zen Hei Mono"
		];
		monospace = [
			"JetBrainsMono Nerd Font"
			"Noto Sans Mono CJK"
			"WenQuanYi Zen Hei Mono"
		];
		emoji = [
			"Noto Color Emoji"
			"Blobmoji"
		];
	};
}
