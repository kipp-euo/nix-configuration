{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # terminal/shell
    compsize
    ffmpeg
    file
    jq
    killall
    lm_sensors
    man-db
    neovim
    nix-index
    wget

    # GUI
    gnome-disk-utility
    gparted
  ];
}
