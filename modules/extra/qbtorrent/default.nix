{ vars, lib, ... }:
let
  download_dir =
    if "${vars.host}" == "pc" then
      "${vars.home}/Storage/Downloads/"
    else
      "/var/lib/qBittorrent";
in
{
  services.qbittorrent = {
    enable = true;
    openFirewall = false;
    user = vars.username;
    group = "users";
    profileDir = download_dir;
  };
  systemd.services.qbittorrent.serviceConfig = {
    ProtectHome = lib.mkForce "tmpfs";
    BindPaths = [ download_dir ];
  };
}
