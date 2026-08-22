{ ... }: {
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      wallpaper = {
        monitor = "";
        path = "~/nix-configuration/assets/wallpapers/1.jxl";
      };
    };
  };
}
