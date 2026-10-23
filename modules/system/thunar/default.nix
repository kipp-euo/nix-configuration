{ pkgs, ... }:
{
  # TODO: Put more configuration in here
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
      thunar-media-tags-plugin
    ];
  };
  services.tumbler.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  programs.dconf.enable = true;
  programs.xfconf.enable = true;
  environment.systemPackages = with pkgs; [
    file-roller
    # p7zip
    # zip
    # unzip
    # unrar
  ];
}
