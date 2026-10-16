{ ... }:
{
  # https://firefox-admin-docs.mozilla.org/reference/policies/
  imports = [
    ./extensions.nix
    ./homepage_tabs.nix
    ./preferences.nix
    ./security_and_privacy.nix
    ./theme.nix
    ./topbar.nix
  ];

  programs.firefox = {
    enable = true;
    profiles.default.isDefault = true;
  };
}
