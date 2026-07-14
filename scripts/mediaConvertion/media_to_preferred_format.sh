#!/usr/bin/bash
set -eEuo pipefail


trap 'echo "An error occurred."' ERR
trap 'echo "Interrupted by CTRL+C."' SIGINT


to_jxl() { ~/.dotfiles/Scripts/MediaConversion/to_jxl.sh "$1" "$2"; }

size_difference() {
	S1="$(stat -c%s "$1")"
	S2="$(stat -c%s "$2")"
	if (( $(echo "$S1 / "$S2" >= 1" | bc -l) )); then
		COLOR="\e[32m"
	else
		COLOR="\e[31m"
	fi
	echo -n "$COLOR$(du -sbh "$1" | cut -f1) -> $(du -sbh "$2" | cut -f1)\e[0m"
}

print_result() {
	echo -e "[ $TYPE_CAPS -> $1 ][ $(size_difference "$IN" "$OUT") ] ${IN##*/}"

}

process_batch() {
	for IN in "$@"; do
		if [[ ! -f "$IN" ]]; then
			echo "$IN is not a file."
			continue
		fi
		IN_SIZE=$(stat -c %s "$IN")

		NAME_NO_FORMAT="${IN%.*}"

		TYPE=$(xdg-mime query filetype "$IN")
		TYPE_CAPS="${TYPE#*/}"
		TYPE_CAPS="${TYPE_CAPS^^}"

		case "$TYPE" in
			video/*)
				continue
				if ffprobe -v error -show_streams -select_streams a "$IN" | grep -q "codec_type=audio"; then
					AUDIO=(-c:a libopus -b:a 128k -vbr on)
				else
					AUDIO=(-an)
				fi
				OUT="${NAME_NO_FORMAT}.mkv"
				if [[ "$OUT" == "$IN" ]]; then
					print_result "$TYPE_CAPS"
				else 
					ffmpeg -i "$IN" \
						-y -loglevel warning -threads 0 \
						-af "aresample=async=1" \
						-c:v libx265 -crf 22 -preset medium -pix_fmt yuv444p10le \
						-x265-params "aq-mode=2:strong-intra-smoothing=0" \
						${AUDIO[@]} \
						"$OUT"
					print_result "MKV (H.265/OPUS)"
				fi
				;;
			audio/*)
				continue
				OUT="${NAME_NO_FORMAT}.flac"
				if [[ "$OUT" != "$IN" ]]; then
					ffmpeg -i "$IN" \
						-y -loglevel warning -strict experimental -threads 0 \
						-c:v copy \
						-c:a flac -compression_level 12 \
						"$OUT"
				fi
				print_result "FLAC"
				;;
			image/*)
				OUT="${NAME_NO_FORMAT}.jxl"
				to_jxl "$IN" "$OUT"
				print_result "JXL"
				;;
			*)
				print_result "$TYPE_CAPS"
				;;
		esac
	done
}


if [ $# -eq 0 ]; then
	echo "No files selected."
	exit 1
fi

FILES=("$@")
echo "Starting conversion for $# files."
process_batch "${FILES[@]}"
echo "Finished conversion."
