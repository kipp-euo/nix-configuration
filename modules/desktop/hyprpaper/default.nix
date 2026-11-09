{ vars, ... }: {
  home-manager.users.${vars.username} = {
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
  };
}
