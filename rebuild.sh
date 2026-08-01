set -e

cd "$(dirname "$0")"

git add .
sudo nixos-rebuild switch --flake .#laptop
hyprctl reload
systemctl --user restart waybar
