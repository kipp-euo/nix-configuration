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
          [class*="avatar"],
          [class*="mask"],
          foreignObject,
          [class*="wrapper"] > svg {
              border-radius: 0 !important;
              mask: none !important;
              clip-path: none !important;
          }
          [class*="avatar"] img,
          [class*="wrapper"] img {
              border-radius: 0 !important;
          }
          border-radius: 0 !important;
        }
        :root, body {
          --font-primary: "JetBrainsMono Nerd Font Thin", "JetBrainsMono Nerd Font", "Noto Sans Mono CJK", "Noto Color Emoji", monospace;
          --font-display: "JetBrainsMono Nerd Font Thin", "JetBrainsMono Nerd Font", "Noto Sans Mono CJK", "Noto Color Emoji", monospace;
          --font-headline: "JetBrainsMono Nerd Font Thin", "JetBrainsMono Nerd Font", "Noto Sans Mono CJK", "Noto Color Emoji", monospace;
          --font-code: "JetBrainsMono Nerd Font", "Noto Sans Mono CJK", "Noto Color Emoji", monospace;
        }

        code, pre, [class*="codeBlockText"] {
          font-family: var(--font-code) !important;
        }
      '';
    };
  };
}
