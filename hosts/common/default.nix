{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  networking.hostName = "pcbg";
  networking.networkmanager.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:caps_toggle";
    variant = "";
  };
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
    ../../modules/system/nix
    ../../modules/system/ntfs
    ../../modules/system/qbtorrent
    ../../modules/system/security
    ../../modules/system/sober
    ../../modules/system/steam
    ../../modules/system/swap
    ../../modules/system/thunar
    ../../modules/system/timezone
    ../../modules/system/users
  ];
  environment.systemPackages = with pkgs; [
    compsize
    curl
    ffmpeg
    gcc
    gnome-disk-utility
    gparted
    jq
    killall
    lm_sensors
    man-db
    neovim
    wget

    nix-index
  ];
  system.stateVersion = "26.05";
}
