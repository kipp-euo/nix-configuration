{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    protontricks.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.steam.extraCompatPackages = with pkgs; [
    proton-ge-bin
    dwproton-bin
  ];
}
