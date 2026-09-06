set -euo pipefail

if [[ ! -f "$1" || -z "$2" ]]; then
	echo "Please specify input and output filenames."
	exit
fi
if [[ $(file --mime-type -b "$1") != video/* ]]; then
	echo "Input is not a video file."
	exit
fi

TARGET_SIZE=$((20 * 1024 * 1024 * 8)) # Bits

MIN_X="$(bc -l <<< scale=0; 720 / 9)"

# 16x * 9x * FPS * BPP = BITRATE
# 16x * 9x * FPS * BPP * DURATION = SIZE
function get_fps() {
	W="$1"
	H="$2"
	B_RATE="$3"
	F=$(bc -l <<< "$B_RATE / ($W * $H * $MIN_BPP)")
	echo $((F > MIN_FPS ? F : MIN_FPS))
}
function get_X() {
	F="$1"
	B_RATE="$2"
	X=$(bc -l <<< "sqrt($B_RATE / ($F* $MIN_BPP * 144))")
	echo $((X > MIN_X ? X : MIN_X))
}

VIDEO_INFO="$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height,r_frame_rate,duration,bit_rate -output_format json -i "$1")"

W=$(echo "$VIDEO_INFO" | jq --raw-output '.streams.[].width')
H=$(echo "$VIDEO_INFO" | jq --raw-output '.streams.[].height')

DURATION=$(echo "$VIDEO_INFO" | jq --raw-output '.streams.[].duration')
DURATION=${DURATION%.*}

FPS=$(($(echo "$VIDEO_INFO" | jq --raw-output '.streams.[].r_frame_rate')))

BITRATE=$(echo "$VIDEO_INFO" | jq --raw-output '.streams.[].bit_rate')

# 1. Get video's bits per pixel
BPP=$((BITRATE / (FPS * W * H)))

# 2. Try to reach target size by reducing BPP and bitrate
L_BPP=$(bc -l <<< "$BPP / 2")
L_SIZE=$(bc -l <<< "$W * $H * $FPS * $L_BPP * $DURATION")
if (( L_SIZE > TARGET_SIZE )); then
	
fi



X=$(get_X $FPS $TARGET_BITRATE)

H=$(bc -l <<< "scale=0; 9 * $X / 1")
if ((H < H)); then
	W=$((W * H / H))
	H=$H
fi

# So that W % 2 == 0 and H % 2 == 0
W=$((W / 2 * 2))
H=$((H / 2 * 2))

# The actual bitrate after getting the resolution
BITRATE=$(bc -l <<< "scale=0; $W * $H * $FPS * $BPP / 1")

echo "Resolution: ${W}x${H}"
echo "Fps: $FPS"
echo "Duration: ${DURATION}"
echo "Bitrate: $((BITRATE / 1000)) Kbps"
echo "Expected file size: $(bc -l <<< "scale=2; $DURATION * $BITRATE / 8 / 1024 / 1024") MiB"

ffmpeg -v error -i "$1" -preset "medium" \
	-b:v "${BITRATE}" -vf "scale=$W:$H" -r $FPS \
	-c:v libx265 -crf 30 \
	-b:a 64K \
	"$2"
