{ ... }:
{
  # TODO: Color scheme
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "adwaita";
      theme_background = false;
      truecolor = true;
      vim_keys = true;
      disable_mouse = false;
      rounded_corners = false;
      terminal_sync = true;
      graph_symbol = "braille";
      update_ms = 2000;
      show_cpu_freq = true;
      freq_mode = "range";
      background_update = true;
    };
  };
}
