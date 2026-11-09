{ pkgs, vars, ... }:
{
  programs.home-manager.enable = true;
  home = {
    username = "${vars.username}";
    homeDirectory = "${vars.home}";
    stateVersion = "26.05";
    packages = with pkgs; [
      # davinci-resolve
      audacious
      audacity
      bc
      kdePackages.kolourpaint
      libjxl
      libreoffice
      qrencode
      tree
    ];
    sessionPath = [ "$HOME/.local/bin" ];
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
    ./prismlauncher
    ./qt
    ./rofi
    ./swappy
    ./swayimg
    ./thunar
    ./vesktop
    ./waybar
  ];
}
