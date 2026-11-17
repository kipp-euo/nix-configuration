{ pkgs, vars, ... }:
{
  programs.steam = {
    package = pkgs.steam.override {
      extraEnv = {
        MANGOHUD = "1";
      };
      extraPkgs = pkgs: [ pkgs.mangohud ];
    };
  };

  home-manager.users.${vars.username} = {
    programs.mangohud = {
      enable = true;
      settings = {
        af = 16;

        toggle_fps_limit = "Shift_L+F1";
        toggle_hud = "Shift_R+F12";
        reset_fps_metrics = "Shift_R+F9";
        reload_cfg = "Shift_L+F4";

        toggle_logging = "Shift_L+F2";
        output_folder = "${vars.documents_dir}/Benchmarks";
        benchmark_percentiles = "AVG,97,1,0.1";

        position = "bottom-left";
        horizontal_stretch = 0;
        horizontal = true;
        hud_compact = true;
        hud_no_margin = true;
        text_outline = false;
        background_color = "1E1D35";
        text_color = "F7F7FF";

        font_size = 16;
        no_small_font = true;
        font_file = "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono/JetBrainsMonoNerdFont-Regular.ttf";

        fps_limit = "120,150,180,200,240,0,60,90";
        fps_limit_method = "early";
        show_fps_limit = true;

        fps = true;
        fps_metrics = "avg,0.01,0.001";
        frametime = true;
        frame_timing = true;

        cpu_stats = true;
        cpu_temp = true;
        gpu_stats = true;
        gpu_temp = true;
        io_read = true;
        io_write = true;
        ram = true;
        swap = true;
        throttling_status = true;
        vram = true;
      };
    };
  };
}
