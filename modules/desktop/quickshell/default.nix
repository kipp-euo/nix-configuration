{ pkgs, lib, ... }:
let
  qmlPath = lib.makeSearchPath "lib/qt-6/qml" [
    pkgs.kdePackages.qtdeclarative
    pkgs.quickshell
  ];

  # Keep QML colors sourced from the repository's shared Nix palette.
  colors = import ../../../colors.nix;

  telemetry = pkgs.callPackage ./telemetry/package.nix { };
  worldclock = pkgs.callPackage ./worldclock/package.nix { };
  audiometer = pkgs.callPackage ./audiometer/package.nix { };
  filesystems = pkgs.callPackage ./disk/package.nix { };

  quickshellConfig = pkgs.runCommand "quickshell-topbar-config" { } ''
    mkdir -p "$out"
    cp -R ${./config}/. "$out/"
    rm -f "$out/Palette.js.in"
    substitute ${./config/Palette.js.in} "$out/Palette.js" \
      --replace-fail @WHITE@ '${colors.white}' \
      --replace-fail @LIGHT_GRAY@ '${colors.light_gray}' \
      --replace-fail @GRAY@ '${colors.gray}' \
      --replace-fail @DARK_GRAY@ '${colors.dark_gray}' \
      --replace-fail @BLACK@ '${colors.black}' \
      --replace-fail @VIOLET@ '${colors.violet}' \
      --replace-fail @LIGHT_VIOLET@ '${colors.light_violet}' \
      --replace-fail @MID_VIOLET@ '${colors.mid_violet}' \
      --replace-fail @DARK_VIOLET@ '${colors.dark_violet}' \
      --replace-fail @BLUE@ '${colors.blue}' \
      --replace-fail @LIGHT_BLUE@ '${colors.light_blue}' \
      --replace-fail @DEEP_BLUE@ '${colors.deep_blue}' \
      --replace-fail @INDIGO@ '${colors.indigo}' \
      --replace-fail @PINK@ '${colors.pink}' \
      --replace-fail @GREEN@ '${colors.green}'
  '';
in
{
  services.upower.enable = true;

  hm = {
    home.packages = [ telemetry worldclock filesystems audiometer pkgs.smartmontools ];

    home.sessionVariables = {
      QML_IMPORT_PATH = qmlPath;
      QS_TELEMETRY = "${telemetry}/bin/qs-telemetry";
      QS_AUDIOMETER = "${audiometer}/bin/qs-audiometer";
      QS_WORLDCLOCK = "${worldclock}/bin/qs-worldclock";
      QS_FILESYSTEMS = "${filesystems}/bin/qs-filesystems";
      QS_SMARTCTL = "${pkgs.smartmontools}/bin/smartctl";
    };

    programs.quickshell = {
      enable = true;
      systemd.enable = true;
      configs = {
        main = quickshellConfig;
      };
      activeConfig = "main";
    };
  };
}
