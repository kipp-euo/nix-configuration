{ pkgs, vars, ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.variables = [ "--all" ];
  };
  home.packages = with pkgs; [
    brightnessctl
    grimblast
    hyprpaper
    hyprpicker
    hyprpolkitagent
    playerctl
    wl-clipboard
  ];

    xdg.configFile = {
      "hypr/hyprtoolkit.conf".text = ''
        background = 0xFFF7F7FF
        base = 0xFFE9E9F3
        alternate_base = 0xFFDDCFFF
        text = 0xFF1E1D35
        bright_text = 0xFFF7F7FF
        accent = 0xFF8000FF
        accent_secondary = 0xFF5E00CC
        link_text = 0xFF0044CC

        rounding_large = 0
        rounding_small = 0

        font_family = JetBrainsMono Nerd Font
        font_family_monospace = JetBrainsMono Nerd Font Mono
        font_size = 11
        icon_theme = Papirus
      '';
      "hypr/xdph.conf".text = ''
        screencopy {
          allow_token_by_default = true
        }
      '';
    };

  services.wl-clip-persist.enable = true;
  services.cliphist.enable = true;

  services.hyprpolkitagent.enable = true;

  wayland.windowManager.hyprland.extraConfig = builtins.foldl' (x: y: x + "\n" + y + "\n") "" [
    ''
      config_dir = "${vars.config_dir}"
    ''
    (builtins.readFile ./config/actions.lua)
    (builtins.readFile ./config/animations.lua)
    (builtins.readFile ./config/autostart.lua)
    (builtins.readFile ./config/colors.lua)
    (builtins.readFile ./config/env.lua)
    (builtins.readFile ./config/input.lua)
    (builtins.readFile ./config/keybinds.lua)
    (builtins.readFile ./config/look_and_feel.lua)
    (builtins.readFile ./config/misc.lua)
    (builtins.readFile ./config/monitors.lua)
    (builtins.readFile ./config/windows_and_workspaces.lua)
  ];
}
