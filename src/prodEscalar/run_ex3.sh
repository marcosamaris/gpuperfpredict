#!/bin/bash

set -e

N=256
DEV_ID=0
MAX_N=10000000
#PROFILE="nvprof --print-gpu-trace"

while true; do
  echo -e "\nRunning ./dot_gpu "${N}" "${DEV_ID}""
  ${PROFILE} ./dot_gpu "${N}" "${DEV_ID}"

  let "N *= 2"
  if [ "${N}" -gt "${MAX_N}" ]; then
    break
  fi
done
