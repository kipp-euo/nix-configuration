{ ... }:
{
  networking.firewall = {
    enable = true;

    # Minecraft
    allowedTCPPorts = [ 25565 ];
    allowedUDPPorts = [ 25565 ];
  };
}

