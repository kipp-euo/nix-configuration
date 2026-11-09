{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    audacious
    audacity
    gnome-disk-utility
    gparted
    kdePackages.kolourpaint
    libreoffice
  ];
}
