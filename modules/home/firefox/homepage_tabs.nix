{ ... }:
{
  programs.firefox.profiles.default.settings = {
    "browser.newtabpage.pinned" = [
      {
        title = "Youtube";
        url = "https://youtube.com";
      }
      {
        title = "Telegram";
        url = "https://web.telegram.org/k/";
      }
      {
        title = "Gemini";
        url = "https://gemini.google.com";
      }
      {
        title = "NixOS options";
        url = "https://search.nixos.org/options";
      }
    ];
  };
}
