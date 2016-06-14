#!/bin/bash

declare -a gpus=( GTX-680 Tesla-K20 Titan Quadro TitanBlack TitanX GTX-970 )


for gpu in "${gpus[@]}"; do
	cd $gpu
	for i in 1 2 3 4 5 6 7 8 9 10; do
		cp traces/run_$i/subSeqMax-* traces_16/run_$(( $i - 1 ))/
	done
	cd ..
done
