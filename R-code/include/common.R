
gpus <- read.table("./Datasets//deviceInfo.csv", sep=",", header=T)
NoGPU <- dim(gpus)[1]

cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

apps <- c("backprop", "gaussian", "heartwall",  "hotspot", "hotspot3D", "lavaMD", "lud", "nw","matMul", "matAdd", "vecAdd", "dotProd", "subSeqMax") #bpnn_layerforward_CUDA

kernelsDict <- vector(mode="list", length=13)
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
                        "needle_cuda_shared_2"
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

kernel_1_parameter <- c(1,2,3,4,5,8,9,10,11)
kernel_2_parameter <- c(6,7,12,13)

featuresTransLog <- c("input.size.1",
                      "elapsed_cycles_sm",
                      "gld_inst_32bit",
                      "gst_inst_32bit",
                      "warps_launched", 
                      "inst_executed",
                      "inst_issued1",
                      "inst_issued2",
                      "shared_load",
                      "shared_store",
                      "gld_request",
                      "gst_request",
                      "active_cycles",
                      "integer_instructions",
                      "issued_load.store_instructions",
                      "misc_instructions",
                      "floating_point_operations.single_precision_add.",
                      "floating_point_operations.single_precision.",
                      "floating_point_operations.double_precision.",
                      "floating_point_operations.double_precision_add.",
                      "floating_point_operations.double_precision_mul.",
                      "floating_point_operations.double_precison_fma.",
                      "floating_point_operations.single_precision_special.",
                      "fp_instructions.double.",
                      
                      "issue_slots",
                      "executed_load.store_instructions",
                      "active_warps",
                      "sm_cta_launched",
                      "grid.y",
                      "load.store_instructions",
                      "global_load_transactions",
                      "global_store_transactions",
                      "device_memory_read_transactions",
                      "shared_store_transactions",
                      "l2_read_transactions",
                      "l2_write_transactions",
                      "issued_control.flow_instructions",
                      "executed_control.flow_instructions",
                      "control.flow_instructions"
                    )

featuresTransNorm <- c("multiprocessor_activity", "executed_ipc", "achieved_occupancy")

featuresTransOther <- c("registers.per.thread", "static.smem")


featuresEfficiency <- c("shared_memory_efficiency", "global_memory_load_efficiency","global_memory_store_efficiency")

featuresThroughput <-c("device_memory_read_throughput", "device_memory_write_throughput", "global_store_throughput",
                       "global_load_throughput")
                       
featuresThroughput <- c("issue_slot_utilization")

# "issued_ipc"

# shared_memory_load_transactions_per_request
# shared_memory_store_transactions_per_request
# global_load_transactions_per_request
