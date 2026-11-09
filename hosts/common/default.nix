{ ... }:
{
  # imports = map (path: ../../modules/system + "/${path}") [
  imports = [
    ../../modules/system/core/audio
    ../../modules/system/core/bluetooth
    ../../modules/system/core/bootloader
    ../../modules/system/core/btrfs
    ../../modules/system/core/fonts
    ../../modules/system/core/git
    ../../modules/system/core/kernel
    ../../modules/system/core/locale
    ../../modules/system/core/nix
    ../../modules/system/core/powermanagement
    ../../modules/system/core/security
    ../../modules/system/core/swap
    ../../modules/system/core/timezone
    ../../modules/system/core/users

    ../../modules/system/extra/appimage-run
    ../../modules/system/extra/flatpak
    ../../modules/system/extra/gpuScreenRecorder
    ../../modules/system/extra/hypr
    ../../modules/system/extra/kdeconnect
    ../../modules/system/extra/ntfs
    ../../modules/system/extra/programming
    ../../modules/system/extra/qbtorrent
    ../../modules/system/extra/thunar
    ../../modules/system/extra/utils
    ../../modules/system/extra/webcam
    ../../modules/system/extra/wine

    ../../modules/system/gaming/gamemode
    ../../modules/system/gaming/sober
    ../../modules/system/gaming/steam

    ../../modules/system/network/dns
    ../../modules/system/network/firewall
    ../../modules/system/network/network
    # ../../modules/system/network/vpn
    ../../modules/system/network/yggdrasil
    ../../modules/system/network/zapret
  ];
  system.stateVersion = "26.05";
}
