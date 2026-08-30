{ ... }:
{
  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    user = "qbittorrent";
    group = "qbittorrent";
  };

  users.users.qbittorrent = {
    isSystemUser = true;
    group = "qbittorrent";
  };
  users.groups.qbittorrent = {};
}
