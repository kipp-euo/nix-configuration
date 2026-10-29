{ vars, ... }:
{
  programs.firefox = {
    languagePacks = [
      "ru-RU"
      "en-US"
    ];
    policies = {
      FirefoxHome = {
        Locked = false;
        Search = true;
        TopSites = true;
        SponsoredTopSites = false;
        Highlights = true;
        Snippets = true;
      };
      DefaultDownloadDirectory = "${vars.home}/Downloads";
      PictureInPicture = true;
      DisableAccounts = true;
      DisableFirefoxScreenshots = true;
      GenerativeAI = {
        Chatbot = false;
        Locked = false;
      };
    };
    profiles.default = {
      settings = {
        "general.autoScroll" = true;
        "sidebar.verticalTabs" = true;
        "browser.startup.page" = 3;
        "intl.locale.requested" = "ru,en-US";
        "sidebar.main.tools" = "opentabs,history";
      };
    };
  };
}
