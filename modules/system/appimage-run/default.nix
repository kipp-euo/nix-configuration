{ pkgs, ... }:
{
  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override
    {
      extraPkgs = pkgs: with pkgs; [
        libayatana-appindicator
        libayatana-indicator
        ayatana-ido
        libdbusmenu
        libepoxy
      ];
    };
  };
}
