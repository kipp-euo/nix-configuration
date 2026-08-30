{ ... }:
{
  networking.hostName = "pcbg";
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  networking.networkmanager.dns = "none";
  networking.nameservers = [ "127.0.0.1" "::1" ];

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
