{ pkgs, vars, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      steam = prev.steam.override (old: {
        extraEnv = (old.extraEnv or { }) // {
          MANGOHUD = "1";
        };
        extraPkgs =
          p:
          (if old ? extraPkgs then old.extraPkgs p else [ ])
          ++ [
            p.mangohud
          ];
      });
    })
  ];

  hm = {
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

        # кадры
        fps = true;
        fps_metrics = "avg,0.01,0.001";
        frametime = true;
        frame_timing = true;

        # CPU
        cpu_stats = true;
        cpu_temp = true;
        cpu_mhz = true;
        core_load = true;
        core_bars = true;

        # GPU
        gpu_stats = true;
        gpu_temp = true;
        gpu_core_clock = true;
        gpu_mem_clock = true;
        throttling_status = true;
        vram = true;

        # память и диск
        ram = true;
        swap = true;
        procmem = true;
        io_read = true;
        io_write = true;
      };
    };
  };
}
