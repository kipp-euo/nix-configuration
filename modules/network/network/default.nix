{ pkgs, vars, ... }:
{
  networking.hostName = vars.hostname;
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    # What is my ISP doing again?
    bmon
    curl
    dig
    dnsutils
    doggo
    drill
    ethtool
    iftop
    ldns
    mtr
    netcat
    ngrep
    nmap
    socat
    tcpdump
  ];
  
  # Tethering masking
  boot.kernel.sysctl = {
    "net.ipv4.ip_default_ttl" = 65;
    "net.ipv6.conf.all.hop_limit" = 65;
  };
}
