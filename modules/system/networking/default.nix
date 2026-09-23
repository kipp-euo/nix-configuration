{ pkgs, ... }:
{
  networking.hostName = "pcbg";
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    # What is my ISP doing again?
    doggo
    dnsutils
    dig
    ldns
    drill
    mtr
    nmap
    netcat
    curl
    tcpdump
    socat
    bandwhich
    ethtool
    iftop
    wireshark
    wireshark-cli
    ngrep
    bmon
  ];

  # Tethering masking
  boot.kernel.sysctl = {
    "net.ipv4.ip_default_ttl" = 65;
    "net.ipv6.conf.all.hop_limit" = 65;
  };
  networking.nameservers = [ "127.0.0.1" ];
  networking.networkmanager.dns = "none";
  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      sources.public-resolvers = {
        urls = [ "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md" ];
        cache_file = "public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        refresh_delay = 72;
      };
      # server_names = [ "cloudflare" ];
      cache = true;
      doh_servers = true;
      require_dnssec = true;
      require_nolog = true;
      require_nofilter = true;
    };
  };
}
