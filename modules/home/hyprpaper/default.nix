{ vars, ... }: {
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      wallpaper = {
        monitor = "";
        path = "${vars.config_dir}/assets/wallpapers/1.jxl";
      };
    };
  };
}
