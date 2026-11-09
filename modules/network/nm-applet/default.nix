{ vars, ... }:
{
  home-manager.users.${vars.username} = {
    services.network-manager-applet.enable = true;
  };
}
