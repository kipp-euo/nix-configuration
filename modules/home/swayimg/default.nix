{ ... }:
{
  # TODO: Migrate config
  programs.swayimg = {
    enable = true;
    initLua = ./config/init.lua;
  };
  xdg.mimeApps.defaultApplications."image/*" = [ "swayimg.desktop" ];
}
