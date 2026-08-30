set -e

cd "$(dirname "$0")"

mkdir -p "lock_backups"
BACKUP="$(mktemp -p "./lock_backups" "$(date "+%Y%m%d")-XXXXXX.back")"
cp flake.lock "$BACKUP"

sudo nix flake update
bash ./rebuild.sh
