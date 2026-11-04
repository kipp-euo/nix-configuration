{ vars, lib, ... }:
let
  download_dir =
    if "${vars.host}" == "pc" then
      "${vars.home}/Storage/Downloads/"
    else
      "${vars.home}/Downloads";
in
{
  services.qbittorrent = {
    enable = true;
    openFirewall = false;
    user = "qbittorrent";
    group = "qbittorrent";
    profileDir = download_dir;
  };
  systemd.services.qbittorrent.serviceConfig = {
    ProtectHome = lib.mkForce "tmpfs";
    BindPaths = [ download_dir ];
  };

  users.users.qbittorrent = {
    isSystemUser = true;
    group = "qbittorrent";
  };
  users.groups.qbittorrent = { };
}
