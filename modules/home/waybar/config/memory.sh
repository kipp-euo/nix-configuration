RAM=$(free | grep Mem | awk '{printf "%.2f", $3/1024^2}')
VRAM=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits | awk '{printf "%.2f", $1/1024}')
echo "$RAM GiB | $VRAM GiB"
