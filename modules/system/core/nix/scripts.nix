{ pkgs, vars, ... }:
let
  rebuild_sh = ''
    git add .
    sudo nixos-rebuild switch --fallback --flake .#${vars.host}
    hyprctl reload
    systemctl --user restart waybar
  '';
in
{
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "Nix-rebuild";
      text = ''
        cd ${vars.config_dir}
        ${rebuild_sh}
      '';
    })
    (pkgs.writeShellApplication {
      name = "Nix-update";
      text = ''
        cd ${vars.config_dir}

        if [[ -f "flake.lock" ]]; then
          BACKUP_DIR="lock_backups"
          mkdir -p "$BACKUP_DIR"

          BACKUP="$(sha256sum "flake.lock" | cut -d' ' -f1)_flake.lock"

          if [ ! -f "$BACKUP_DIR/$BACKUP" ]; then
            cp flake.lock "$BACKUP_DIR/$BACKUP"
          fi
        fi
        nix flake update

        ${rebuild_sh}
      '';
    })
  ];
}
