{ pkgs, ... }:
{
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  programs.hyprland = {
    enable = true;
    withUWSM = false;
  };
  programs.uwsm.enable = false;
  xdg.portal = {
    enable = true;
    # extraPortals = with pkgs; [
    #   xdg-desktop-portal-hyprland
    #   xdg-desktop-portal-gtk
    # ];
  };
  xdg.portal.config.common.default = [
    "hyprland"
    "gtk"
  ];

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    # Required so non-root users are allowed to use the above substituter/keys.
    # Use @wheel for all sudo users, or list your username explicitly.
    trusted-users = ["root" "@wheel"];
  };
}
