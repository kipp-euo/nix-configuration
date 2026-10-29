{ ... }:
{
  imports = [
    ./config.nix
  ];
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = builtins.readFile ./config/style.css;
  };
}
