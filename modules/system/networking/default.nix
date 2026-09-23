{ ... }:
{
  networking.hostName = "pcbg";
  networking.networkmanager.enable = true;

  # Tethering masking
  boot.kernel.sysctl = {
    "net.ipv4.ip_default_ttl" = 65;
    "net.ipv6.conf.all.hop_limit" = 65;
  };
}
