{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = false;
  };
  programs.uwsm.enable = false;
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };
  security.polkit.enable = true;
  environment.systemPackages = with pkgs; [
    hyprpolkitagent
  ];
}
