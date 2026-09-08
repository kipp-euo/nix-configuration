{ pkgs, ... }:
{
  imports = [
    ../../modules/system/appimage-run
    ../../modules/system/audio
    ../../modules/system/bluetooth
    ../../modules/system/bootloader/systemd-boot
    ../../modules/system/btrfs
    ../../modules/system/firewall
    ../../modules/system/flatpak
    ../../modules/system/fonts
    ../../modules/system/gamemode
    ../../modules/system/git
    ../../modules/system/gpuScreenRecorder
    ../../modules/system/hypr
    ../../modules/system/kernel
    ../../modules/system/locale
    ../../modules/system/networking
    ../../modules/system/nix
    ../../modules/system/ntfs
    ../../modules/system/kdeconnect
    ../../modules/system/qbtorrent
    ../../modules/system/security
    ../../modules/system/sober
    ../../modules/system/steam
    ../../modules/system/swap
    ../../modules/system/thunar
    ../../modules/system/timezone
    ../../modules/system/users
    ../../modules/system/webcam
    ../../modules/system/zapret
  ];
  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    systemPackages = with pkgs; [
      compsize
      curl
      ffmpeg
      file
      gcc
      gnome-disk-utility
      gparted
      jdk
      jq
      killall
      lm_sensors
      man-db
      neovim
      nix-index
      wget
    ];
  };
  system.stateVersion = "26.05";
}
