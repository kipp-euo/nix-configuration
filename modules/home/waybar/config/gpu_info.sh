#!/bin/bash

GPU_INFO=$(nvidia-smi --query-gpu=utilization.gpu,clocks.current.graphics --format=csv,noheader,nounits | tr -d ' ')

UTIL=$(echo "$GPU_INFO" | awk -F',' '{print $1}')
FREQ=$(echo "$GPU_INFO" | awk -F',' '{print $2}')

echo "$UTIL% | $FREQ MHz"

