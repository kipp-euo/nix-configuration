#!/usr/bin/bash
set -euo pipefail


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
trap 'echo "Error: Could not finish conversion."' ERR

IN="$1"


if [[ "$(xdg-mime query filetype "$IN")" == image/jxl ]]; then
	if grep -q "jbrd" "$IN"; then
		if [[ $# -eq 1 ]]; then
			OUT="${IN%.*}.jpg"
		else
			OUT="$2"
		fi
		djxl --quiet --num_threads=-1 --output_format="jpg" "$IN" "$OUT"
	elif [[ "$(jxlinfo -v "$IN" 2>/dev/null || true)" == *"have_animation: 1"* ]]; then
		if [[ $# -eq 1 ]]; then
			OUT="${IN%.*}.webp"
		else
			OUT="$2"
		fi
		TEMP_APNG="$(temp_file "$IN").apng"
		djxl --quiet --num_threads=-1 "$IN" --output_format="png" "$TEMP_APNG"
		ffmpeg -threads 0 -y -loglevel error -i "$TEMP_APNG" \
			-c:v libwebp -lossless 1 -loop 0 -an -f webp "$OUT"
	else
		if [[ $# -eq 1 ]]; then
			OUT="${IN%.*}.png"
		else
			OUT="$2"
		fi
		djxl --quiet --num_threads=-1 --output_format="png" "$IN" "$OUT"
	fi
else
	echo "$IN is not a JXL file."
	exit 1
fi
