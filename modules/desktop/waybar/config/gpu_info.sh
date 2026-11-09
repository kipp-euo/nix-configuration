if ! command -v nvidia-smi >/dev/null 2>&1; then
	UTIL="$(cat /sys/class/drm/card1/device/gpu_busy_percent)"
	FREQ="$(cat /sys/class/drm/card1/device/hwmon/hwmon*/freq1_input | awk '{print $1/1000000}')"
else
	GPU_INFO=$(nvidia-smi --query-gpu=utilization.gpu,clocks.current.graphics --format=csv,noheader,nounits | tr -d ' ')
	UTIL=$(echo "$GPU_INFO" | awk -F',' '{print $1}')
	FREQ=$(echo "$GPU_INFO" | awk -F',' '{print $2}')
fi
TEXT="$UTIL% | $FREQ MHz"

echo "$TEXT"

