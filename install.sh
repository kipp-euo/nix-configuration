set -e

cd "$(dirname "$0")"

# TODO: Make swapfile

mkdir -p ~/Applications
mkdir -p ~/Downloads
mkdir -p ~/Documents
mkdir -p ~/Media/Images/Screenshots
mkdir -p ~/Media/Videos/ScreenRecordings

bash ./rebuild.sh
