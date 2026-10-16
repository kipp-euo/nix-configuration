{ ... }:
{
  programs.firefox = {
    profiles.default = {
      userChrome = ''
        .titlebar-close {
            display: none !important;
        }
      '';
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.uiCustomization.state" = ''
          {
            "placements": {
              "widget-overflow-fixed-list": [],
              "unified-extensions-area": [
                "_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action"
              ],
              "nav-bar": [
                "reset-pbm-toolbar-button",
                "back-button",
                "forward-button",
                "stop-reload-button",
                "urlbar-container",
                "vertical-spacer",
                "ublock0_raymondhill_net-browser-action",
                "sponsorblocker_ajay_app-browser-action",
                "browsec_browsec_com-browser-action",
                "downloads-button",
                "unified-extensions-button",
                "smartwindow-group-tabs-button",
                "ai-window-toggle"
              ],
              "toolbar-menubar": [
                "menubar-items"
              ],
              "TabsToolbar": [],
              "vertical-tabs": [
                "tabbrowser-tabs"
              ],
              "PersonalToolbar": [
                "import-button",
                "personal-bookmarks"
              ]
            },
            "seen": [
              "reset-pbm-toolbar-button",
              "smartwindow-group-tabs-button",
              "ai-window-toggle",
              "developer-button",
              "_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action",
              "ublock0_raymondhill_net-browser-action",
              "sponsorblocker_ajay_app-browser-action",
              "browsec_browsec_com-browser-action"
            ],
            "dirtyAreaCache": [
              "nav-bar",
              "TabsToolbar",
              "vertical-tabs",
              "PersonalToolbar",
              "unified-extensions-area",
              "toolbar-menubar"
            ],
            "currentVersion": 28,
            "newElementCount": 7
          }
        '';
      };
    };
  };
}
