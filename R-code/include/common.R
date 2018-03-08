
gpus <- read.table("./datasets/deviceInfo.csv", sep=",", header=T)
NoGPU <- dim(gpus)[1]

cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

apps <- c("backprop", "gaussian", "heartwall",  "hotspot", "hotspot3D", "lavaMD", "lud", "nw","matMul", "matAdd", "vecAdd", "dotProd", "subSeqMax") 

kernelsDict <- vector(mode="list", length=22)
names(kernelsDict) <- c("bpnn_layerforward_CUDA",
                        "bpnn_adjust_weights_cuda",
                        "Fan1",
                        "Fan2",
                        "kernel",
                        "calculate_temp",
                        "hotspotOpt1",
                        "kernel_gpu_cuda",
                        "lud_diagonal",
                        "lud_perimeter",
                        "lud_internal",
                        "needle_cuda_shared_1",
                        "needle_cuda_shared_2",
                        "matMul_gpu_uncoalesced",
                        "matMul_gpu",
                        "matMul_gpu_sharedmem_uncoalesced",
                        "matMul_gpu_sharedmem",
                        "matrix_sum_normal",
                        "matrix_sum_coalesced",
                        "dotProd",
                        "vectorAdd",
                        "subSeqMax"
)



kernelsDict[[1]] <- apps[1]
kernelsDict[[2]] <- apps[1]
kernelsDict[[3]] <- apps[2]
kernelsDict[[4]] <- apps[2]
kernelsDict[[5]] <- apps[3]
kernelsDict[[6]] <- apps[4]
kernelsDict[[7]] <- apps[5]
kernelsDict[[8]] <- apps[6]
kernelsDict[[9]] <- apps[7]
kernelsDict[[10]] <- apps[7]
kernelsDict[[11]] <- apps[7]
kernelsDict[[12]] <- apps[8]
kernelsDict[[13]] <- apps[8]


kernelsDict[[14]] <- apps[9]
kernelsDict[[15]] <- apps[9]
kernelsDict[[16]] <- apps[9]
kernelsDict[[17]] <- apps[9]
kernelsDict[[18]] <- apps[10]
kernelsDict[[19]] <- apps[10]
kernelsDict[[20]] <- apps[11]
kernelsDict[[21]] <- apps[12]
kernelsDict[[22]] <- apps[13]


kernel_1_parameter <- c(1,2,3,4,5,8,9,10,11)
kernel_2_parameter <- c(6,7,12,13)

