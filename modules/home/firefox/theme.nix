{ ... }:
{
  programs.firefox = {
    policies.ExtensionSettings = {
      "{aab1adac-5449-47fd-b836-c2f43dc28f3f}" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/file/4552784/profiles_violet-1.0.xpi";
        installation_mode = "normal_installed";
        private_browsing = true;
      };
    };
    profiles.default = {
      settings = {
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
      userContent = ''
        * {
          border-radius: 0 !important;
        }
        body, p, article, main, h1, h2, h3, li {
          font-family: "JetBrainsMono Nerd Font Thin";
        }
      '';
    };
  };
}
