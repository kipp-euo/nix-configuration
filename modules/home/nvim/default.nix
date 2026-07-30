{ config, pkgs, ... }:
{
	xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-configuration/modules/home/nvim/config";
	home.sessionVariables = {
		EDITOR = "nvim";
		VISUAL = "nvim";
		MANPAGER = "nvim +Man!";
	};
	xdg.mimeApps.defaultApplications."text/plain" = [ "nvim.desktop" ];
	home.shellAliases = {
		vi = "nvim";
		vim = "nvim";
	};
	home.packages = with pkgs; [
		neovim
		
		# LPS
		bash-language-server
		clang
		docker-language-server
		hyprls
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
