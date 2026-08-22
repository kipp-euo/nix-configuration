{ ... }:
{
  programs.swappy = {
    enable = true;
    settings = {
      Default = {
        auto_save = false;
        fill_shape = false;
        show_panel = true;
        early_exit = true;
        transparent = false;
        transparency = 50;
        line_size = 5;
        text_size = 20;
        text_font = "sans-serif";
        paint_mode = "brush";
        save_dir = "$HOME/Media/Images/Screenshots";
        save_filename_format = "swappy-%Y%m%d-%H%M%S.%N.png";
        custom_color = "rgba(128,0,255,1)";
      };
    };
  };
}
