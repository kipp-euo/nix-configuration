{ vars, ... }:
{
  home-manager.users.${vars.username} = {
    programs.bash = {
      enable = true;
      historyControl = [
        "ignoredups"
        "erasedups"
      ];
      initExtra = ''
        PS1="\[\e[35m\][\u@\h \w]\$ \[\e[m\]"
      '';
    };
    home.shellAliases = {
      ll = "ls -lav --color=auto --group-directories-first";
    };
  };
}
