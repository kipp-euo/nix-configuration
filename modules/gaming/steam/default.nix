{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      steam = prev.steam.override (old: {
        extraEnv = (old.extraEnv or { }) // {
          PROTON_ENABLE_WAYLAND = "1";
          SDL_VIDEODRIVER = "wayland,x11";
        };
      });
    })
  ];
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
  # environment.systemPackages = with pkgs; [
  #   adwsteamgtk
  # ];
}
