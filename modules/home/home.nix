{ pkgs, ... }:
{
  programs.home-manager.enable = true;
  home = {
    username = "kipp";
    homeDirectory = "/home/kipp";
    stateVersion = "26.05"; 
    packages = with pkgs; [
      audacious
      audacity
      bc
      davinci-resolve
      kdePackages.kolourpaint
      libjxl
      libreoffice
      qrencode
      tree
    ];
  };
  imports = [
    # ./mime
    ./bash
    ./btop
    ./development
    ./fastfetch
    ./firefox
    ./fonts
    ./foot
    ./gtk
    ./hypr
    ./hyprpaper
    ./mako
    ./mpv
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
  ];
}
