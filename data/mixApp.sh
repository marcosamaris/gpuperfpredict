#/bin/bash

gpu=TitanX

declare -a apps=( dotProd vectorAdd matrix_sum_normal matrix_sum_coalesced matMul_gpu_sharedmem  matMul_gpu_sharedmem_uncoalesced matMul_gpu_uncoalesced matMul_gpu)


mkdir -p $gpu/block
for app in "${apps[@]}"; do
    cat $gpu/block_8/$app-kernel-traces.csv $gpu/block_16/$app-kernel-traces.csv
    cat 


