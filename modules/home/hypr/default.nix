{ pkgs, ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.variables = [ "--all" ];
  };
  home.packages = with pkgs; [
    hyprpaper
    hyprpicker
    grimblast
    wl-clipboard
    cliphist
    brightnessctl
    playerctl
    hyprpolkitagent
  ];
  xdg.portal.config.common.default = [
    "hyprland"
    "gtk"
  ];
  wayland.windowManager.hyprland.extraConfig = builtins.foldl' (x: y: x + "\n" + y + "\n") "" [
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
