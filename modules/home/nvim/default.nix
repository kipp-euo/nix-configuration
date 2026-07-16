{ config, pkgs, ... }:
{
	xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/NixOS-configuration/modules/home/nvim/config";
	home.sessionVariables = {
		EDITOR = "nvim";
		VISUAL = "nvim";
		MANPAGER = "nvim +Man!";
	};
	home.packages = with pkgs; [
		neovim
		
		# LPS
		bash-language-server
		clang
		docker-language-server
		lua-language-server
		marksman
		nixd
		pyright
		rust-analyzer
		systemd-language-server
		texlab
		vscode-langservers-extracted
	];
}
