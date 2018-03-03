
gpus <- read.table("./data/deviceInfo.csv", sep = ",", header = T)
NoGPU <- dim(gpus)[1]

apps <- c("matMul_gpu_uncoalesced","matMul_gpu", "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem",
          "matrix_sum_normal", "matrix_sum_coalesced", 
          "dotProd", "vectorAdd",  "subSeqMax")

namesMetrics30 <- read.csv("./data/metricsNames-3.0.csv",header = T, sep = ",")
namesEvents30 <- read.csv("./data/eventsNames-3.0.csv", header = T, sep = ",")

namesMetrics35 <- read.csv("./data/metricsNames-3.5.csv",header = T, sep = ",")
namesEvents35 <- read.csv("./data/eventsNames-3.5.csv", header = T, sep = ",")

namesMetrics50 <- read.csv("./data/metricsNames-5.0.csv",header = T, sep = ",")
namesEvents50 <- read.csv("./data/eventsNames-5.0.csv", header = T, sep = ",")

namesMetrics52 <- read.csv("./data/metricsNames-5.2.csv",header = T, sep = ",")
namesEvents52 <- read.csv("./data/eventsNames-5.2.csv", header = T, sep = ",")

namesTraces <- read.csv("./data/tracesNames.csv",header = T, sep = ",")



traceNames <-
    read.csv("./data/tracesNames.csv", header = T, sep = ",")

colnames(metricNames50)[which(names(metricNames50) == "global_load")] <-
    "gld_request"
colnames(metricNames50)[which(names(metricNames50) == "global_store")] <-
    "gst_request"
colnames(metricNames50)[which(names(metricNames50) == "sm_efficiency")] <-
    "multiprocessor_activity"
colnames(metricNames50)[which(names(metricNames50) == "ipc")] <-
    "executed_ipc"
colnames(metricNames50)[which(names(metricNames50) == "inst_per_warp")] <-
    "instructions_per_warp"
colnames(metricNames50)[which(names(metricNames50) == "inst_replay_overhead")] <-
    "instruction_replay_overhead"
colnames(metricNames50)[which(names(metricNames50) == "shared_load_transactions_per_request")] <-
    "shared_memory_load_transactions_per_request"
colnames(metricNames50)[which(names(metricNames50) == "shared_store_transactions_per_request")] <-
    "shared_memory_store_transactions_per_request"
colnames(metricNames50)[which(names(metricNames50) == "local_load_transactions_per_request")] <-
    "local_memory_load_transactions_per_request"
colnames(metricNames50)[which(names(metricNames50) == "local_store_transactions_per_request")] <-
    "local_memory_store_transactions_per_request"
colnames(metricNames50)[which(names(metricNames50) == "gld_transactions_per_request")] <-
    "global_load_transactions_per_request"
colnames(metricNames50)[which(names(metricNames50) == "gst_transactions_per_request")] <-
    "global_store_transactions_per_request"
colnames(metricNames50)[which(names(metricNames50) == "gld_transactions")] <-
    "global_load_transactions"
colnames(metricNames50)[which(names(metricNames50) == "gst_transactions")] <-
    "global_store_transactions"
colnames(metricNames50)[which(names(metricNames50) == "dram_read_transactions")] <-
    "device_memory_read_transactions"
colnames(metricNames50)[which(names(metricNames50) == "dram_write_transactions")] <-
    "device_memory_store_transactions"
colnames(metricNames50)[which(names(metricNames50) == "global_hit_rate")] <-
    "l2_hit_rate_(l1_reads)"
colnames(metricNames50)[which(names(metricNames50) == "gld_requested_throughput")] <-
    "requested_global_load_throughput"
colnames(metricNames50)[which(names(metricNames50) == "gst_requested_throughput")] <-
    "requested_global_store_throughput"
colnames(metricNames50)[which(names(metricNames50) == "gld_throughput")] <-
    "global_load_throughput"
colnames(metricNames50)[which(names(metricNames50) == "gst_throughput")] <-
    "global_store_throughput"
colnames(metricNames50)[which(names(metricNames50) == "dram_read_throughput")] <-
    "device_memory_read_throughput"
colnames(metricNames50)[which(names(metricNames50) == "dram_write_throughput")] <-
    "device_memory_write_throughput"
colnames(metricNames50)[which(names(metricNames50) == "local_load_throughput")] <-
    "local_memory_load_throughput"
colnames(metricNames50)[which(names(metricNames50) == "local_store_throughput")] <-
    "local_memory_store_throughput"
colnames(metricNames50)[which(names(metricNames50) == "shared_load_throughput")] <-
    "shared_memory_load_throughput"
colnames(metricNames50)[which(names(metricNames50) == "shared_store_throughput")] <-
    "shared_memory_store_throughput"
colnames(metricNames50)[which(names(metricNames50) == "gld_efficiency")] <-
    "global_memory_load_efficiency"
colnames(metricNames50)[which(names(metricNames50) == "gst_efficiency")] <-
    "global_memory_store_efficiency"
colnames(metricNames50)[which(names(metricNames50) == "tex_cache_transactions")] <-
    "texture_cache_transactions"
colnames(metricNames50)[which(names(metricNames50) == "cf_fu_utilization")] <-
    "control.flow_function_unit_utilization"
colnames(metricNames50)[which(names(metricNames50) == "tex_fu_utilization")] <-
    "texture_function_unit_utilization"
colnames(metricNames50)[which(names(metricNames50) == "ldst_fu_utilization")] <-
    "load.store_function_unit_tilization"
colnames(metricNames50)[which(names(metricNames50) == "flop_count_dp")] <-
    "floating_point_operations.double_precision."
colnames(metricNames50)[which(names(metricNames50) == "flop_count_dp_add")] <-
    "floating_point_operations.double_precision_add."
colnames(metricNames50)[which(names(metricNames50) == "flop_count_dp_mul")] <-
    "floating_point_operations.double_precision_mul."
colnames(metricNames50)[which(names(metricNames50) == "flop_count_dp_fma")] <-
    "floating_point_operations.double_precison_fma."
colnames(metricNames50)[which(names(metricNames50) == "flop_count_sp")] <-
    "floating_point_operations.single_precision."
colnames(metricNames50)[which(names(metricNames50) == "flop_count_sp_add")] <-
    "floating_point_operations.single_precision_add."
colnames(metricNames50)[which(names(metricNames50) == "flop_count_sp_mul")] <-
    "floating_point_operations.single_precision_mul."
colnames(metricNames50)[which(names(metricNames50) == "flop_count_sp_fma")] <-
    "floating_point_operations.single_precison_fma."
colnames(metricNames50)[which(names(metricNames50) == "flop_count_sp_special")] <-
    "floating_point_operations.single_precision_special."
colnames(metricNames50)[which(names(metricNames50) == "dram_utilization")] <-
    "device_memory_utilization"
colnames(metricNames50)[which(names(metricNames50) == "shared_efficiency")] <-
    "shared_memory_efficiency"
colnames(metricNames50)[which(names(metricNames50) == "shared_utilization")] <-
    "l1.shared_memory_utilization"
colnames(metricNames50)[which(names(metricNames50) == "inst_fp_32")] <-
    "fp_instructions.single."
colnames(metricNames50)[which(names(metricNames50) == "inst_fp_64")] <-
    "fp_instructions.double."
colnames(metricNames50)[which(names(metricNames50) == "inst_integer")] <-
    "integer_instructions"
colnames(metricNames50)[which(names(metricNames50) == "inst_bit_convert")] <-
    "bit-convert_instructions"
colnames(metricNames50)[which(names(metricNames50) == "inst_control")] <-
    "control.flow_instructions"
colnames(metricNames50)[which(names(metricNames50) == "inst_compute_ld_st")] <-
    "load.store_instructions"
colnames(metricNames50)[which(names(metricNames50) == "inst_misc")] <-
    "misc_instructions"
colnames(metricNames50)[which(names(metricNames50) == "inst_inter_thread_communication")] <-
    "inter-thread_instructions"
colnames(metricNames50)[which(names(metricNames50) == "cf_issued")] <-
    "issued_control.flow_instructions"
colnames(metricNames50)[which(names(metricNames50) == "cf_executed")] <-
    "executed_control.flow_instructions"
colnames(metricNames50)[which(names(metricNames50) == "ldst_issued")] <-
    "issued_load.store_instructions"
colnames(metricNames50)[which(names(metricNames50) == "ldst_executed")] <-
    "executed_load.store_instructions"
colnames(metricNames50)[which(names(metricNames50) == "stall_inst_fetch")] <-
    "issue_stall_reasons_.instructions_fetch."
colnames(metricNames50)[which(names(metricNames50) == "stall_exec_dependency")] <-
    "issue_stall_reasons_.execution_dependency."
colnames(metricNames50)[which(names(metricNames50) == "stall_memory_dependency")] <-
    "issue_stall_reasons_.data_request."
colnames(metricNames50)[which(names(metricNames50) == "stall_texture")] <-
    "issue_stall_reasons_.texture."
colnames(metricNames50)[which(names(metricNames50) == "stall_sync")] <-
    "issue_stall_reasons_.synchronization."
colnames(metricNames50)[which(names(metricNames50) == "stall_other")] <-
    "issue_stall_reasons_.other."
colnames(metricNames50)[which(names(metricNames50) == "stall_constant_memory_dependency")] <-
    "issue_stall_reasons_.immediate_constant."
colnames(metricNames50)[which(names(metricNames50) == "stall_pipe_busy")] <-
    "issue_stall_reasons_.pipe_busy."
colnames(metricNames50)[which(names(metricNames50) == "stall_memory_throttle")] <-
    "issue_stall_reasons_.memory_throttle."
colnames(metricNames50)[which(names(metricNames50) == "stall_not_selected")] <-
    "issue_stall_reasons_.not_selected."
colnames(metricNames50)[which(names(metricNames50) == "sysmem_read_transactions")] <-
    "system_memory_read_transactions"
colnames(metricNames50)[which(names(metricNames50) == "sysmem_write_transactions")] <-
    "system_memory_write_transactions"
colnames(metricNames50)[which(names(metricNames50) == "l2_read_throughput")] <-
    "l2_throughput_.reads."
colnames(metricNames50)[which(names(metricNames50) == "l2_write_throughput")] <-
    "l2_throughput_.writes."
colnames(metricNames50)[which(names(metricNames50) == "sysmem_read_throughput")] <-
    "system_memory_read_throughput"
colnames(metricNames50)[which(names(metricNames50) == "sysmem_write_throughput")] <-
    "system_memory_write_throughput"
colnames(metricNames50)[which(names(metricNames50) == "l2_utilization")] <-
    "L2_cache_utilization"
colnames(metricNames50)[which(names(metricNames50) == "l2_atomic_throughput")] <-
    "l2_throughput_.atomic_requests."
colnames(metricNames50)[which(names(metricNames50) == "l2_atomic_transactions")] <-
    "l2_transactions_.atomic_requests."
colnames(metricNames50)[which(names(metricNames50) == "sysmem_utilization")] <-
    "system_memory_utilization"
colnames(metricNames50)[which(names(metricNames50) == "eligible_warps_per_cycle")] <-
    "eligible_warps_per_active_cycle"
colnames(metricNames50)[which(names(metricNames50) == "flop_sp_efficiency")] <-
    "flop_efficiency.peak_single."
colnames(metricNames50)[which(names(metricNames50) == "flop_dp_efficiency")] <-
    "flop_efficiency.peak_double."


colnames(metricNames52)[which(names(metricNames52) == "global_load")] <-
    "gld_request"
colnames(metricNames52)[which(names(metricNames52) == "global_store")] <-
    "gst_request"
colnames(metricNames52)[which(names(metricNames52) == "sm_efficiency")] <-
    "multiprocessor_activity"
colnames(metricNames52)[which(names(metricNames52) == "ipc")] <-
    "executed_ipc"
colnames(metricNames52)[which(names(metricNames52) == "inst_per_warp")] <-
    "instructions_per_warp"
colnames(metricNames52)[which(names(metricNames52) == "inst_replay_overhead")] <-
    "instruction_replay_overhead"
colnames(metricNames52)[which(names(metricNames52) == "shared_load_transactions_per_request")] <-
    "shared_memory_load_transactions_per_request"
colnames(metricNames52)[which(names(metricNames52) == "shared_store_transactions_per_request")] <-
    "shared_memory_store_transactions_per_request"
colnames(metricNames52)[which(names(metricNames52) == "local_load_transactions_per_request")] <-
    "local_memory_load_transactions_per_request"
colnames(metricNames52)[which(names(metricNames52) == "local_store_transactions_per_request")] <-
    "local_memory_store_transactions_per_request"
colnames(metricNames52)[which(names(metricNames52) == "gld_transactions_per_request")] <-
    "global_load_transactions_per_request"
colnames(metricNames52)[which(names(metricNames52) == "gst_transactions_per_request")] <-
    "global_store_transactions_per_request"
colnames(metricNames52)[which(names(metricNames52) == "gld_transactions")] <-
    "global_load_transactions"
colnames(metricNames52)[which(names(metricNames52) == "gst_transactions")] <-
    "global_store_transactions"
colnames(metricNames52)[which(names(metricNames52) == "dram_read_transactions")] <-
    "device_memory_read_transactions"
colnames(metricNames52)[which(names(metricNames52) == "dram_write_transactions")] <-
    "device_memory_store_transactions"
colnames(metricNames52)[which(names(metricNames52) == "global_hit_rate")] <-
    "l2_hit_rate_(l1_reads)"
colnames(metricNames52)[which(names(metricNames52) == "gld_requested_throughput")] <-
    "requested_global_load_throughput"
colnames(metricNames52)[which(names(metricNames52) == "gst_requested_throughput")] <-
    "requested_global_store_throughput"
colnames(metricNames52)[which(names(metricNames52) == "gld_throughput")] <-
    "global_load_throughput"
colnames(metricNames52)[which(names(metricNames52) == "gst_throughput")] <-
    "global_store_throughput"
colnames(metricNames52)[which(names(metricNames52) == "dram_read_throughput")] <-
    "device_memory_read_throughput"
colnames(metricNames52)[which(names(metricNames52) == "dram_write_throughput")] <-
    "device_memory_write_throughput"
colnames(metricNames52)[which(names(metricNames52) == "local_load_throughput")] <-
    "local_memory_load_throughput"
colnames(metricNames52)[which(names(metricNames52) == "local_store_throughput")] <-
    "local_memory_store_throughput"
colnames(metricNames52)[which(names(metricNames52) == "shared_load_throughput")] <-
    "shared_memory_load_throughput"
colnames(metricNames52)[which(names(metricNames52) == "shared_store_throughput")] <-
    "shared_memory_store_throughput"
colnames(metricNames52)[which(names(metricNames52) == "gld_efficiency")] <-
    "global_memory_load_efficiency"
colnames(metricNames52)[which(names(metricNames52) == "gst_efficiency")] <-
    "global_memory_store_efficiency"
colnames(metricNames52)[which(names(metricNames52) == "tex_cache_transactions")] <-
    "texture_cache_transactions"
colnames(metricNames52)[which(names(metricNames52) == "cf_fu_utilization")] <-
    "control.flow_function_unit_utilization"
colnames(metricNames52)[which(names(metricNames52) == "tex_fu_utilization")] <-
    "texture_function_unit_utilization"
colnames(metricNames52)[which(names(metricNames52) == "ldst_fu_utilization")] <-
    "load.store_function_unit_tilization"
colnames(metricNames52)[which(names(metricNames52) == "flop_count_dp")] <-
    "floating_point_operations.double_precision."
colnames(metricNames52)[which(names(metricNames52) == "flop_count_dp_add")] <-
    "floating_point_operations.double_precision_add."
colnames(metricNames52)[which(names(metricNames52) == "flop_count_dp_mul")] <-
    "floating_point_operations.double_precision_mul."
colnames(metricNames52)[which(names(metricNames52) == "flop_count_dp_fma")] <-
    "floating_point_operations.double_precison_fma."
colnames(metricNames52)[which(names(metricNames52) == "flop_count_sp")] <-
    "floating_point_operations.single_precision."
colnames(metricNames52)[which(names(metricNames52) == "flop_count_sp_add")] <-
    "floating_point_operations.single_precision_add."
colnames(metricNames52)[which(names(metricNames52) == "flop_count_sp_mul")] <-
    "floating_point_operations.single_precision_mul."
colnames(metricNames52)[which(names(metricNames52) == "flop_count_sp_fma")] <-
    "floating_point_operations.single_precison_fma."
colnames(metricNames52)[which(names(metricNames52) == "flop_count_sp_special")] <-
    "floating_point_operations.single_precision_special."
colnames(metricNames52)[which(names(metricNames52) == "dram_utilization")] <-
    "device_memory_utilization"
colnames(metricNames52)[which(names(metricNames52) == "shared_efficiency")] <-
    "shared_memory_efficiency"
colnames(metricNames52)[which(names(metricNames52) == "shared_utilization")] <-
    "l1.shared_memory_utilization"
colnames(metricNames52)[which(names(metricNames52) == "inst_fp_32")] <-
    "fp_instructions.single."
colnames(metricNames52)[which(names(metricNames52) == "inst_fp_64")] <-
    "fp_instructions.double."
colnames(metricNames52)[which(names(metricNames52) == "inst_integer")] <-
    "integer_instructions"
colnames(metricNames52)[which(names(metricNames52) == "inst_bit_convert")] <-
    "bit-convert_instructions"
colnames(metricNames52)[which(names(metricNames52) == "inst_control")] <-
    "control.flow_instructions"
colnames(metricNames52)[which(names(metricNames52) == "inst_compute_ld_st")] <-
    "load.store_instructions"
colnames(metricNames52)[which(names(metricNames52) == "inst_misc")] <-
    "misc_instructions"
colnames(metricNames52)[which(names(metricNames52) == "inst_inter_thread_communication")] <-
    "inter-thread_instructions"
colnames(metricNames52)[which(names(metricNames52) == "cf_issued")] <-
    "issued_control.flow_instructions"
colnames(metricNames52)[which(names(metricNames52) == "cf_executed")] <-
    "executed_control.flow_instructions"
colnames(metricNames52)[which(names(metricNames52) == "ldst_issued")] <-
    "issued_load.store_instructions"
colnames(metricNames52)[which(names(metricNames52) == "ldst_executed")] <-
    "executed_load.store_instructions"
colnames(metricNames52)[which(names(metricNames52) == "stall_inst_fetch")] <-
    "issue_stall_reasons_.instructions_fetch."
colnames(metricNames52)[which(names(metricNames52) == "stall_exec_dependency")] <-
    "issue_stall_reasons_.execution_dependency."
colnames(metricNames52)[which(names(metricNames52) == "stall_memory_dependency")] <-
    "issue_stall_reasons_.data_request."
colnames(metricNames52)[which(names(metricNames52) == "stall_texture")] <-
    "issue_stall_reasons_.texture."
colnames(metricNames52)[which(names(metricNames52) == "stall_sync")] <-
    "issue_stall_reasons_.synchronization."
colnames(metricNames52)[which(names(metricNames52) == "stall_other")] <-
    "issue_stall_reasons_.other."
colnames(metricNames52)[which(names(metricNames52) == "stall_constant_memory_dependency")] <-
    "issue_stall_reasons_.immediate_constant."
colnames(metricNames52)[which(names(metricNames52) == "stall_pipe_busy")] <-
    "issue_stall_reasons_.pipe_busy."
colnames(metricNames52)[which(names(metricNames52) == "stall_memory_throttle")] <-
    "issue_stall_reasons_.memory_throttle."
colnames(metricNames52)[which(names(metricNames52) == "stall_not_selected")] <-
    "issue_stall_reasons_.not_selected."
colnames(metricNames52)[which(names(metricNames52) == "sysmem_read_transactions")] <-
    "system_memory_read_transactions"
colnames(metricNames52)[which(names(metricNames52) == "sysmem_write_transactions")] <-
    "system_memory_write_transactions"
colnames(metricNames52)[which(names(metricNames52) == "l2_read_throughput")] <-
    "l2_throughput_.reads."
colnames(metricNames52)[which(names(metricNames52) == "l2_write_throughput")] <-
    "l2_throughput_.writes."
colnames(metricNames52)[which(names(metricNames52) == "sysmem_read_throughput")] <-
    "system_memory_read_throughput"
colnames(metricNames52)[which(names(metricNames52) == "sysmem_write_throughput")] <-
    "system_memory_write_throughput"
colnames(metricNames52)[which(names(metricNames52) == "l2_utilization")] <-
    "l2_cache_utilization"
colnames(metricNames52)[which(names(metricNames52) == "l2_atomic_throughput")] <-
    "l2_throughput_.atomic_requests."
colnames(metricNames52)[which(names(metricNames52) == "l2_atomic_transactions")] <-
    "l2_transactions_.atomic_requests."
colnames(metricNames52)[which(names(metricNames52) == "sysmem_utilization")] <-
    "system_memory_utilization"
colnames(metricNames52)[which(names(metricNames52) == "eligible_warps_per_cycle")] <-
    "eligible_warps_per_active_cycle"
colnames(metricNames52)[which(names(metricNames52) == "flop_sp_efficiency")] <-
    "flop_efficiency.peak_single."
colnames(metricNames52)[which(names(metricNames52) == "flop_dp_efficiency")] <-
    "flop_efficiency.peak_double."

colnames(metricNames52.970)[which(names(metricNames52.970) == "global_load")] <-
    "gld_request"
colnames(metricNames52.970)[which(names(metricNames52.970) == "global_store")] <-
    "gst_request"
colnames(metricNames52.970)[which(names(metricNames52.970) == "sm_efficiency")] <-
    "multiprocessor_activity"
colnames(metricNames52.970)[which(names(metricNames52.970) == "ipc")] <-
    "executed_ipc"
colnames(metricNames52.970)[which(names(metricNames52.970) == "inst_per_warp")] <-
    "instructions_per_warp"
colnames(metricNames52.970)[which(names(metricNames52.970) == "inst_replay_overhead")] <-
    "instruction_replay_overhead"
colnames(metricNames52.970)[which(names(metricNames52.970) == "shared_load_transactions_per_request")] <-
    "shared_memory_load_transactions_per_request"
colnames(metricNames52.970)[which(names(metricNames52.970) == "shared_store_transactions_per_request")] <-
    "shared_memory_store_transactions_per_request"
colnames(metricNames52.970)[which(names(metricNames52.970) == "local_load_transactions_per_request")] <-
    "local_memory_load_transactions_per_request"
colnames(metricNames52.970)[which(names(metricNames52.970) == "local_store_transactions_per_request")] <-
    "local_memory_store_transactions_per_request"
colnames(metricNames52.970)[which(names(metricNames52.970) == "gld_transactions_per_request")] <-
    "global_load_transactions_per_request"
colnames(metricNames52.970)[which(names(metricNames52.970) == "gst_transactions_per_request")] <-
    "global_store_transactions_per_request"
colnames(metricNames52.970)[which(names(metricNames52.970) == "gld_transactions")] <-
    "global_load_transactions"
colnames(metricNames52.970)[which(names(metricNames52.970) == "gst_transactions")] <-
    "global_store_transactions"
colnames(metricNames52.970)[which(names(metricNames52.970) == "dram_read_transactions")] <-
    "device_memory_read_transactions"
colnames(metricNames52.970)[which(names(metricNames52.970) == "dram_write_transactions")] <-
    "device_memory_store_transactions"
colnames(metricNames52.970)[which(names(metricNames52.970) == "global_hit_rate")] <-
    "l2_hit_rate_(l1_reads)"
colnames(metricNames52.970)[which(names(metricNames52.970) == "gld_requested_throughput")] <-
    "requested_global_load_throughput"
colnames(metricNames52.970)[which(names(metricNames52.970) == "gst_requested_throughput")] <-
    "requested_global_store_throughput"
colnames(metricNames52.970)[which(names(metricNames52.970) == "gld_throughput")] <-
    "global_load_throughput"
colnames(metricNames52.970)[which(names(metricNames52.970) == "gst_throughput")] <-
    "global_store_throughput"
colnames(metricNames52.970)[which(names(metricNames52.970) == "dram_read_throughput")] <-
    "device_memory_read_throughput"
colnames(metricNames52.970)[which(names(metricNames52.970) == "dram_write_throughput")] <-
    "device_memory_write_throughput"
colnames(metricNames52.970)[which(names(metricNames52.970) == "local_load_throughput")] <-
    "local_memory_load_throughput"
colnames(metricNames52.970)[which(names(metricNames52.970) == "local_store_throughput")] <-
    "local_memory_store_throughput"
colnames(metricNames52.970)[which(names(metricNames52.970) == "shared_load_throughput")] <-
    "shared_memory_load_throughput"
colnames(metricNames52.970)[which(names(metricNames52.970) == "shared_store_throughput")] <-
    "shared_memory_store_throughput"
colnames(metricNames52.970)[which(names(metricNames52.970) == "gld_efficiency")] <-
    "global_memory_load_efficiency"
colnames(metricNames52.970)[which(names(metricNames52.970) == "gst_efficiency")] <-
    "global_memory_store_efficiency"
colnames(metricNames52.970)[which(names(metricNames52.970) == "tex_cache_transactions")] <-
    "texture_cache_transactions"
colnames(metricNames52.970)[which(names(metricNames52.970) == "cf_fu_utilization")] <-
    "control.flow_function_unit_utilization"
colnames(metricNames52.970)[which(names(metricNames52.970) == "tex_fu_utilization")] <-
    "texture_function_unit_utilization"
colnames(metricNames52.970)[which(names(metricNames52.970) == "ldst_fu_utilization")] <-
    "load.store_function_unit_tilization"
colnames(metricNames52.970)[which(names(metricNames52.970) == "flop_count_dp")] <-
    "floating_point_operations.double_precision."
colnames(metricNames52.970)[which(names(metricNames52.970) == "flop_count_dp_add")] <-
    "floating_point_operations.double_precision_add."
colnames(metricNames52.970)[which(names(metricNames52.970) == "flop_count_dp_mul")] <-
    "floating_point_operations.double_precision_mul."
colnames(metricNames52.970)[which(names(metricNames52.970) == "flop_count_dp_fma")] <-
    "floating_point_operations.double_precison_fma."
colnames(metricNames52.970)[which(names(metricNames52.970) == "flop_count_sp")] <-
    "floating_point_operations.single_precision."
colnames(metricNames52.970)[which(names(metricNames52.970) == "flop_count_sp_add")] <-
    "floating_point_operations.single_precision_add."
colnames(metricNames52.970)[which(names(metricNames52.970) == "flop_count_sp_mul")] <-
    "floating_point_operations.single_precision_mul."
colnames(metricNames52.970)[which(names(metricNames52.970) == "flop_count_sp_fma")] <-
    "floating_point_operations.single_precison_fma."
colnames(metricNames52.970)[which(names(metricNames52.970) == "flop_count_sp_special")] <-
    "floating_point_operations.single_precision_special."
colnames(metricNames52.970)[which(names(metricNames52.970) == "dram_utilization")] <-
    "device_memory_utilization"
colnames(metricNames52.970)[which(names(metricNames52.970) == "shared_efficiency")] <-
    "shared_memory_efficiency"
colnames(metricNames52.970)[which(names(metricNames52.970) == "shared_utilization")] <-
    "l1.shared_memory_utilization"
colnames(metricNames52.970)[which(names(metricNames52.970) == "inst_fp_32")] <-
    "fp_instructions.single."
colnames(metricNames52.970)[which(names(metricNames52.970) == "inst_fp_64")] <-
    "fp_instructions.double."
colnames(metricNames52.970)[which(names(metricNames52.970) == "inst_integer")] <-
    "integer_instructions"
colnames(metricNames52.970)[which(names(metricNames52.970) == "inst_bit_convert")] <-
    "bit-convert_instructions"
colnames(metricNames52.970)[which(names(metricNames52.970) == "inst_control")] <-
    "control.flow_instructions"
colnames(metricNames52.970)[which(names(metricNames52.970) == "inst_compute_ld_st")] <-
    "load.store_instructions"
colnames(metricNames52.970)[which(names(metricNames52.970) == "inst_misc")] <-
    "misc_instructions"
colnames(metricNames52.970)[which(names(metricNames52.970) == "inst_inter_thread_communication")] <-
    "inter-thread_instructions"
colnames(metricNames52.970)[which(names(metricNames52.970) == "cf_issued")] <-
    "issued_control.flow_instructions"
colnames(metricNames52.970)[which(names(metricNames52.970) == "cf_executed")] <-
    "executed_control.flow_instructions"
colnames(metricNames52.970)[which(names(metricNames52.970) == "ldst_issued")] <-
    "issued_load.store_instructions"
colnames(metricNames52.970)[which(names(metricNames52.970) == "ldst_executed")] <-
    "executed_load.store_instructions"
colnames(metricNames52.970)[which(names(metricNames52.970) == "stall_inst_fetch")] <-
    "issue_stall_reasons_.instructions_fetch."
colnames(metricNames52.970)[which(names(metricNames52.970) == "stall_exec_dependency")] <-
    "issue_stall_reasons_.execution_dependency."
colnames(metricNames52.970)[which(names(metricNames52.970) == "stall_memory_dependency")] <-
    "issue_stall_reasons_.data_request."
colnames(metricNames52.970)[which(names(metricNames52.970) == "stall_texture")] <-
    "issue_stall_reasons_.texture."
colnames(metricNames52.970)[which(names(metricNames52.970) == "stall_sync")] <-
    "issue_stall_reasons_.synchronization."
colnames(metricNames52.970)[which(names(metricNames52.970) == "stall_other")] <-
    "issue_stall_reasons_.other."
colnames(metricNames52.970)[which(names(metricNames52.970) == "stall_constant_memory_dependency")] <-
    "issue_stall_reasons_.immediate_constant."
colnames(metricNames52.970)[which(names(metricNames52.970) == "stall_pipe_busy")] <-
    "issue_stall_reasons_.pipe_busy."
colnames(metricNames52.970)[which(names(metricNames52.970) == "stall_memory_throttle")] <-
    "issue_stall_reasons_.memory_throttle."
colnames(metricNames52.970)[which(names(metricNames52.970) == "stall_not_selected")] <-
    "issue_stall_reasons_.not_selected."
colnames(metricNames52.970)[which(names(metricNames52.970) == "sysmem_read_transactions")] <-
    "system_memory_read_transactions"
colnames(metricNames52.970)[which(names(metricNames52.970) == "sysmem_write_transactions")] <-
    "system_memory_write_transactions"
colnames(metricNames52.970)[which(names(metricNames52.970) == "l2_read_throughput")] <-
    "l2_throughput_.reads."
colnames(metricNames52.970)[which(names(metricNames52.970) == "l2_write_throughput")] <-
    "l2_throughput_.writes."
colnames(metricNames52.970)[which(names(metricNames52.970) == "sysmem_read_throughput")] <-
    "system_memory_read_throughput"
colnames(metricNames52.970)[which(names(metricNames52.970) == "sysmem_write_throughput")] <-
    "system_memory_write_throughput"
colnames(metricNames52.970)[which(names(metricNames52.970) == "l2_utilization")] <-
    "l2_cache_utilization"
colnames(metricNames52.970)[which(names(metricNames52.970) == "l2_atomic_throughput")] <-
    "l2_throughput_.atomic_requests."
colnames(metricNames52.970)[which(names(metricNames52.970) == "l2_atomic_transactions")] <-
    "l2_transactions_.atomic_requests."
colnames(metricNames52.970)[which(names(metricNames52.970) == "sysmem_utilization")] <-
    "system_memory_utilization"
colnames(metricNames52.970)[which(names(metricNames52.970) == "eligible_warps_per_cycle")] <-
    "eligible_warps_per_active_cycle"
colnames(metricNames52.970)[which(names(metricNames52.970) == "flop_sp_efficiency")] <-
    "flop_efficiency.peak_single."
colnames(metricNames52.970)[which(names(metricNames52.970) == "flop_dp_efficiency")] <-
    "flop_efficiency.peak_double."

selectedFeatures <- intersect(names(metricNames30), intersect(names(metricNames35), intersect( names(metricNames50), names(metricNames52) )))
intersect(selectedFeatures, names(metricNames52.970))
apps <-
    c("backprop",
      "gaussian",
      "heartwall",
      "hotspot",
      "hotspot3D",
      "lavaMD",
      "lud",
      "nw") #bpnn_layerforward_CUDA

kernelsDict <- vector(mode = "list", length = 13)
names(kernelsDict) <- c(
    "bpnn_layerforward_CUDA",
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

kernel_1_parameter <- c(1, 2, 3, 4, 5, 8, 9, 10, 11)
kernel_2_parameter <- c(6, 7, 12, 13)