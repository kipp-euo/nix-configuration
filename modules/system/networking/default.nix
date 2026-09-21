{ pkgs, ... }:
{
  networking.hostName = "pcbg";
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  # Tethering masking
  boot.kernel.sysctl = {
    "net.ipv4.ip_default_ttl" = 65;
    "net.ipv6.conf.all.hop_limit" = 65;
  };

  networking.networkmanager.dns = "none";
  networking.nameservers = [ "127.0.0.1" "::1" ];

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

  services.unbound = {
    enable = true;
    settings = {
      remote-control.control-enable = true;
      server = {
        interface = [ "127.0.0.1" "::1" ];
        harden-glue = true;
        harden-dnssec-stripped = true;
        use-caps-for-id = false;
        prefetch = true;
        edns-buffer-size = 1232;
        hide-identity = true;
        hide-version = true;
      };
      forward-zone = [
        {
          name = ".";
          forward-tls-upstream = "yes";
          forward-first = "yes"; # Fallback
          forward-addr = [
            "1.1.1.1@853#cloudflare-dns.com"
            "1.0.0.1@853#cloudflare-dns.com"
            "9.9.9.9#dns.quad9.net"
            "149.112.112.112#dns.quad9.net"
          ];
        }
      ];
    };
  };
}
