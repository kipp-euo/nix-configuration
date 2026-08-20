set -e

cd "$(dirname "$0")"

git add .
sudo nixos-rebuild switch --show-trace --flake .#pc
hyprctl reload
systemctl --user restart waybar
