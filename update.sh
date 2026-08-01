set -e

cd "$(dirname "$0")"

BACKUP="$(mktemp -p "./lock_backups" "flake.lock.$(date "+%Y%m%d")-XXXXXX.back")"
cp flake.lock "$BACKUP"

sudo nix flake update
bash ./rebuild.sh
