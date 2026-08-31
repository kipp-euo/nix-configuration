{ ... }:
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = builtins.fromJSON (builtins.readFile ./config/config.jsonc);
    };
    style = builtins.readFile ./config/style.css;
  };
}
