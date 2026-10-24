set -e

cd "$(dirname "$0")"

if [[ -f "flake.lock" ]]; then
	mkdir -p "lock_backups"
	BACKUP="$(mktemp -p "./lock_backups" "$(date "+%Y%m%d")-XXXXXX.back")"
	cp flake.lock "$BACKUP"
fi

sudo nix flake update
bash ./rebuild.sh
