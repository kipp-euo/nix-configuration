{ ... }:
{
  hm = {
    programs.quickshell = {
      enable = true;
      systemd.enable = true;
      systemd.target = "hyprland-session.target";
      configs.main = ./config;
      activeConfig = "main";
    };
  };
}
