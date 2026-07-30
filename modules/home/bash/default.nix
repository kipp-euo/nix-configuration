{ ... }:
{
	programs.bash = {
		enable = true;
		historyControl = [ "ignoredups" "erasedups" ];
		initExtra = ''
			PS1="\[\e[35m\][\u@\h \w]\$ \[\e[m\]"
		'';
	};
}
