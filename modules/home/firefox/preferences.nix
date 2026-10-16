{ ... }:
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
      DefaultDownloadDirectory = "/home/kipp/Downloads";
      PictureInPicture = true;
      DisableAccounts = true;
      DisableFirefoxScreenshots = true;
      GenerativeAI = {
        Chatbot = false;
        Locked = false;
      };
    };
    profiles.kipp = {
      settings = {
        "general.autoScroll" = true;
        "sidebar.verticalTabs" = true;

        # https://addons.mozilla.org/ru/firefox/addon/profiles_violet/
        "extensions.activeThemeID" = "{aab1adac-5449-47fd-b836-c2f43dc28f3f}";

        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      userChrome = ''
        :root {
          --toolbarbutton-border-radius: 0px !important;
          --tab-border-radius: 0px !important;
          --arrowpanel-border-radius: 0px !important;
          --arrowpanel-menuitem-border-radius: 0px !important;
        }
        * {
            border-radius: 0 !important;
        }
      '';
    };
  };
}
