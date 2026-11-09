{ ... }:
{
  # imports = map (path: ../../modules/system + "/${path}") [
  imports = [
    ../../modules/core/audio
    ../../modules/core/bash
    ../../modules/core/bluetooth
    ../../modules/core/bootloader
    ../../modules/core/btrfs
    ../../modules/core/fonts
    ../../modules/core/git
    ../../modules/core/kernel
    ../../modules/core/locale
    ../../modules/core/nix
    ../../modules/core/powermanagement
    ../../modules/core/security
    ../../modules/core/swap
    ../../modules/core/timezone
    ../../modules/core/users

    ../../modules/desktop/firefox
    ../../modules/desktop/foot
    ../../modules/desktop/gtk
    ../../modules/desktop/hypr
    ../../modules/desktop/hyprpaper
    ../../modules/desktop/mako
    ../../modules/desktop/mpv
    ../../modules/desktop/nvim
    ../../modules/desktop/qt
    ../../modules/desktop/rofi
    ../../modules/desktop/swappy
    ../../modules/desktop/swayimg
    ../../modules/desktop/thunar
    ../../modules/desktop/waybar

    ../../modules/extra/appimage-run
    ../../modules/extra/btop
    ../../modules/extra/fastfetch
    ../../modules/extra/flatpak
    ../../modules/extra/gpuScreenRecorder
    ../../modules/extra/gui_apps
    ../../modules/extra/kdeconnect
    ../../modules/extra/ntfs
    ../../modules/extra/programming
    ../../modules/extra/qbtorrent
    ../../modules/extra/utils
    ../../modules/extra/vesktop
    ../../modules/extra/vm
    ../../modules/extra/webcam
    ../../modules/extra/wine

    ../../modules/gaming/gamemode
    ../../modules/gaming/prismlauncher
    ../../modules/gaming/sober
    ../../modules/gaming/steam

    ../../modules/network/bandwhich
    ../../modules/network/dns
    ../../modules/network/firewall
    ../../modules/network/network
    ../../modules/network/nm-applet
    # ../../modules/network/vpn
    ../../modules/network/wireshark
    ../../modules/network/yggdrasil
    ../../modules/network/zapret
  ];
  system.stateVersion = "26.05";
}
