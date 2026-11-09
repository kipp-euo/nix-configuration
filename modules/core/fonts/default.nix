{
  pkgs,
  vars,
  ...
}:
let
  fonts = with pkgs; [
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
in
{
  fonts.fontDir.enable = true;
  fonts.fontconfig.enable = true;
  fonts.fontconfig.useEmbeddedBitmaps = true;
  fonts.packages = fonts;
  home-manager.users.${vars.username} = {
    home.packages = fonts;
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "JetBrainsMono Nerd Font"
          "Noto Sans Mono CJK"
          "WenQuanYi Zen Hei Mono"
        ];
        sansSerif = [
          "JetBrainsMono Nerd Font"
          "Noto Sans Mono CJK"
          "WenQuanYi Zen Hei Mono"
        ];
        monospace = [
          "JetBrainsMono Nerd Font"
          "Noto Sans Mono CJK"
          "WenQuanYi Zen Hei Mono"
        ];
        emoji = [
          "Noto Color Emoji"
          "Blobmoji"
          "Twitter Color Emoji"
        ];
      };
    };
  };
}
