{ ... }:
{
  services.flatpak = {
    enable = true;
    remotes = [{
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }];
    overrides.global.Context.filesystems = [
      "xdg-config/gtk-3.0:ro"
      "xdg-config/gtk-4.0:ro"
    ];
    update = {
      onActivation = false;
      auto = {
        enable = true;
        onCalendar = "weekly";
      };
    };
  };
}
