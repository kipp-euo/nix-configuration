{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bc
    compsize
    ffmpeg
    file
    jq
    killall
    libjxl
    lm_sensors
    man-db
    nix-index
    qrencode
    tree
    wget
  ];
}
