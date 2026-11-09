{ vars, ... }:
{
  imports = [
    ./config.nix
  ];
  home-manager.users.${vars.username} = {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      style = builtins.readFile ./config/style.css;
    };
  };
}
