{ pkgs, ... }:
let
  bg = "#F7F7FF";
  fg = "#1E1D35";
  dim_bg = "#F4F4FC";
  colorsCss = ''
    @define-color window_bg_color ${bg};
    @define-color view_bg_color ${bg};
    @define-color headerbar_bg_color ${bg};
    @define-color headerbar_backdrop_color ${bg};
    @define-color card_bg_color ${bg};
    @define-color dialog_bg_color ${bg};
    @define-color popover_bg_color ${bg};
    @define-color sidebar_bg_color ${bg};

    @define-color window_fg_color ${fg};
    @define-color view_fg_color ${fg};
    @define-color headerbar_fg_color ${fg};
  '';
  squareCss = ''
    * {
      border-radius: 0;
    }
  '';
in
{
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 22;
  };
  gtk = {
    enable = true;
    colorScheme = "light";
    theme = {
      name = "adw-gtk3";
      package = pkgs.adw-gtk3;
    };
    font = {
      name = "JetBrainsMono Nerd Font Mono";
      size = 11;
    };
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme.override { color = "magenta"; };
    };
    gtk3.extraCss = colorsCss + squareCss;
    gtk4.extraCss = colorsCss + squareCss;
  };
}
