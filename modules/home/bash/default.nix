{ config, pkgs, ... }:
{
	programs.bash = {
		enable = true;
		historyControl = [ "ignoredups" "erasedups" ];
		initExtra = ''
			PS1="\[\e[35m\][\u@\H \w]\$ \[\e[m\]"
		'';
	};
}
