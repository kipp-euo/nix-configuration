{ vars, ... }:
{
  home-manager.users.${vars.username} = {
    programs.prismlauncher.enable = true;
  };
}
