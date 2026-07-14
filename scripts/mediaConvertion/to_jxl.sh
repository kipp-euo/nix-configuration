#!/usr/bin/bash
set -eEuo pipefail


if [[ $# -eq 0 ]]; then
	echo "Usage: \$INPUT_FILE [\$OUTPUT_FILE]"
	exit 1
fi
if [[ ! -f "$1" ]]; then
	echo "Invalid input file."
	exit 1
fi

TEMP_DIR=$(mktemp -d)
temp_file() { echo "$TEMP_DIR/$(basename "$1")"; }
cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT
trap 'echo "Could not finish conversion."' ERR


from_jxl() {
	~/.dotfiles/Scripts/MediaConversion/from_jxl.sh "$1" "$2"
}

to_jxl() {
	cjxl --quiet --num_threads=-1 -d 0 -e 7 -j 1 --allow_jpeg_reconstruction=1 "$1" "$2"
}

IN="$1"
if [[ $# -eq 1 ]]; then
	OUT="${IN%.*}.jxl"
else
	OUT="$2"
fi


TYPE="$(xdg-mime query filetype "$IN")"
if [[ "$TYPE" != image/* ]]; then
	echo "File is not an image. Exiting."
	exit 1
fi

if [[ "$TYPE" == image/jxl ]]; then
	TEMP="$(temp_file "$IN")"
	from_jxl "$IN" "$TEMP"
	TYPE="$(xdg-mime query filetype "$TEMP")"
	FORMAT="${TYPE#*/}"
	mv "$TEMP" "$TEMP.$FORMAT"
	TEMP="$TEMP.$FORMAT"
	IN="$TEMP"
fi

if [[ "$TYPE" == image/webp ]]; then
	N=$(webpinfo "$IN" 2>/dev/null | grep -c "Chunk ANMF" || true)
	if [[ $N -gt 0 ]]; then
		FRAMES="$(temp_file "$IN").frames"
		mkdir -p "$FRAMES"
		for ((i = 0; i < N; i++)); do
			webpmux -get frame "$i" "$IN" -o "$FRAMES/$i.webp" &>/dev/null
			dwebp "$FRAMES/$i.webp" -o "$FRAMES/$i.png" &>/dev/null
		done
		DUR="$(webpinfo "$IN" 2>/dev/null | grep "Duration:" | head -n 1 | awk '{print $2}' || true)"
		DUR=${DUR:-100}
		FPS=$(awk -v d="$DUR" 'BEGIN{printf "%.6f", 1000.0/d}')
		TEMP="$(temp_file "$IN").apng"
		ffmpeg -threads 0 -y -loglevel error -framerate "$FPS" \
			-i "$FRAMES/%d.png" -loop 0 -c:v apng -f apng "$TEMP"
		to_jxl "$TEMP" "$OUT"
	else
		TEMP="$(temp_file "$IN").png"
		dwebp "$IN" -o "$TEMP" &>/dev/null
		to_jxl "$TEMP" "$OUT"
	fi
else
	to_jxl "$IN" "$OUT"
fi
