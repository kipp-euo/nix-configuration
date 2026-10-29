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
          mkdir -p "lock_backups"
          BACKUP="$(mktemp -p "./lock_backups" "$(date "+%Y%m%d")-XXXXXX.back")"
          cp flake.lock "$BACKUP"
        fi
        nix flake update

        ${rebuild_sh}
      '';
    })
  ];
}
