{ pkgs, ... }:
{
  fonts.fontDir.enable = true;
  fonts.fontconfig.enable = true;
  fonts.fontconfig.useEmbeddedBitmaps = true;
  fonts.packages = with pkgs; [
    corefonts
    liberation_ttf
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    twitter-color-emoji
    noto-fonts-emoji-blob-bin
    vista-fonts
    wqy_zenhei
  ];
}
