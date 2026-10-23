{ ... }:
{
  imports = [ ./plugins.nix ];

  programs.vesktop = {
    enable = true;
    settings = {
      appBadge = false;
      arRPC = true;
      checkUpdates = false;
      customTitleBar = false;
      disableMinSize = true;
      discordBranch = "stable";
      enableMenu = false;
      enableRoundedCorners = false;
      enableShadow = false;
      hardwareAcceleration = false;
      minimizeToTray = true;
      nativeTitleBar = true;
      splashBackground = "#F7F7FF";
      splashColor = "#1e1d35";
      splashTheming = true;
      staticTitle = true;
      transparencyOption = "none";
    };
    vencord = {
      settings = {
        autoUpdate = false;
        autoUpdateNotification = false;
        disableMinSize = true;
        notifyAboutUpdates = false;
        transparent = false;
        nativeTitleBar = true;
      };
      extraQuickCss = ''
        * {
          border-radius: 0 !important;
        }
      '';
    };
  };
}
