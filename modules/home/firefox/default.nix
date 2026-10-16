{ ... }:
{
  # https://firefox-admin-docs.mozilla.org/reference/policies/
  imports = [
    ./extensions.nix
    ./security_and_privacy.nix
    ./preferences.nix
  ];

  programs.firefox = {
    enable = true;
    profiles.kipp.isDefault = true;
  };
}
