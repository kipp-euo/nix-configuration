{ ... }:
{
  # TODO: More configuration
  programs.firefox = {
    enable = true;
    languagePacks = [
      "ru-RU"
      "en-US"
    ];
    profiles.kipp = {
      isDefault = true;
      settings = {
        "privacy.resistFingerprinting"  = true;
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
