{ ... }:
{
  imports = [
    ../../modules/system/appimage-run
    ../../modules/system/audio
    ../../modules/system/bluetooth
    ../../modules/system/bootloader/systemd-boot
    ../../modules/system/btrfs
    ../../modules/system/dns
    ../../modules/system/firewall
    ../../modules/system/flatpak
    ../../modules/system/fonts
    ../../modules/system/gamemode
    ../../modules/system/git
    ../../modules/system/gpuScreenRecorder
    ../../modules/system/hypr
    ../../modules/system/kdeconnect
    ../../modules/system/kernel
    ../../modules/system/locale
    ../../modules/system/networking
    ../../modules/system/nix
    ../../modules/system/ntfs
    ../../modules/system/powermanagement
    ../../modules/system/qbtorrent
    ../../modules/system/security
    ../../modules/system/sober
    ../../modules/system/steam
    ../../modules/system/swap
    ../../modules/system/thunar
    ../../modules/system/timezone
    ../../modules/system/users
    ../../modules/system/utils

    ../../modules/system/vpn
    # ../../modules/system/zapret
  ];
  system.stateVersion = "26.05";
}
