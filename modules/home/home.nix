{ pkgs, vars, ... }:
{
  programs.home-manager.enable = true;
  home = {
    username = "${vars.username}";
    homeDirectory = "${vars.home}";
    stateVersion = "26.05";
    packages = with pkgs; [
      audacious
      # audacity
      bc
      # davinci-resolve
      kdePackages.kolourpaint
      libjxl
      libreoffice
      qrencode
      tree
    ];
    sessionPath = [ "$HOME/.local/bin" ];
    shellAliases = {
      ll = "ls -lav --color=auto --group-directories-first";
    };
  };

  imports = [
    ./bash
    ./btop
    ./fastfetch
    ./firefox
    ./fonts
    ./foot
    ./gtk
    ./hypr
    ./hyprpaper
    ./mako
    ./mpv
    ./nm-applet
    ./nvim
    ./obsidian
    ./prismlauncher
    ./qt
    ./rofi
    ./sober
    ./swappy
    ./swayimg
    ./thunar
    ./vesktop
    ./waybar

    # ./claude-code
  ];
}
