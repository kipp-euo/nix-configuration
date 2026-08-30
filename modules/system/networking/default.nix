{ ... }:
{
  networking.hostName = "pcbg";
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  networking.dhcpcd.extraConfig = "nohook resolv.conf";
}
