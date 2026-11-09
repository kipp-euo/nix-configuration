{ inputs, pkgs, vars, ... }:
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  users.users.${vars.username}.extraGroups = [ "minecraft" ];

  services.minecraft-server = {
    enable = true;
    package = pkgs.neoforgeServers.neoforge-1_21_1;
    dataDir = "/var/lib/minecraft";
    eula = true;
    jvmOpts = "-Xms4G -Xmx4G";
    openFirewall = true;
    declarative = true;
    serverProperties = {
      motd = "Enhanced AI + Hordes!";

      allow-cheats = false;
      server-port = 25565;
      online-mode = false;
      enforce-secure-profile = false;

      view-distance = 32;
      simulation-distance = 8;

      difficulty = 3;
      gamemode = 0;
      max-players = 20;
      white-list = false;
      enable-rcon = true;
      "rcon.password" = "Gomodrill8";
      "rcon.port" = 25575;
    };
  };
  environment.systemPackages = with pkgs; [ mcrcon ];
}
