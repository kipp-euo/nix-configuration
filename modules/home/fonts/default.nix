{ osConfig, ... }:
{
	fonts.fontconfig = {
		enable = true;
		defaultFonts = {
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
				"Twitter Color Emoji"
			];
		};
	};
	home.packages = osConfig.fonts.packages;
}
