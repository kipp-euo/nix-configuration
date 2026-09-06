{ config, pkgs, ... }:
{
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=10 card_label="Phone Cam" exclusive_caps=1
  '';
  users.users.kipp.extraGroups = [ "adbusers" "video" ];
  environment.systemPackages = with pkgs; [
    v4l-utils
    scrcpy
  ];
}
