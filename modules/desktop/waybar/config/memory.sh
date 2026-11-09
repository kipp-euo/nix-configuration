RAM=$(free | grep Mem | awk '{printf "%.2f", $3/1024^2}')
if ! command -v nvidia-smi >/dev/null 2>&1; then
	VRAM=$(cat /sys/class/drm/card1/device/mem_info_vram_used | awk '{printf "%.2f", $1/1024/1024/1024}')
else
	VRAM=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits | awk '{printf "%.2f", $1/1024}')
fi
echo "$RAM GiB | $VRAM GiB"
