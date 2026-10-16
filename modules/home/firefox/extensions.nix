{ ... }:
{
  programs.firefox.policies.ExtensionSettings = {
    "uBlock0@raymondhill.net" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
      installation_mode = "normal_installed";
    };
    "sponsorBlocker@ajay.app" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
      installation_mode = "normal_installed";
    };
    # Browsec VPN
    "browsec@browsec.com" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/browsec/latest.xpi";
      installation_mode = "normal_installed";
    };
    # YouTube NonStop
    "youtube-nonstop@lawfx" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-nonstop/latest.xpi";
      installation_mode = "normal_installed";
    };
    # Return YouTube Dislike
    "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/return-youtube-dislikes/latest.xpi";
      installation_mode = "normal_installed";
    };
  };
}
