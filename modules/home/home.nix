{ pkgs, ... }:
{
  programs.home-manager.enable = true;
  home = {
    username = "kipp";
    homeDirectory = "/home/kipp";
    stateVersion = "26.05"; 
    packages = with pkgs; [
      kdePackages.kolourpaint
      audacious
      audacity
      bc
      tree
      libjxl
      davinci-resolve
    ];
  };
  imports = [
    # ./mime
    ./vesktop
    ./bash
    ./btop
    ./development
    ./fastfetch
    ./firefox
    ./foot
    ./gtk
    ./hypr
    ./hyprpaper
    ./fonts
    ./libreoffice
    ./mako
    ./mpv
    ./nvim
    ./prismlauncher
    ./qt
    ./rofi
    ./sober
    ./swappy
    ./swayimg
    ./thunar
    ./waybar
  ];
}
