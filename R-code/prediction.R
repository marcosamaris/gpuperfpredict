library(e1071)


dirpath <- "~/Doctorate/svm-gpuperf/"
setwd(paste(dirpath, sep=""))

gpus <- read.table("./ML-model/deviceInfo_L1disabled.csv", sep=",", header=T)
NoGPU <- dim(gpus)[1]

apps <- c("matMul_gpu_uncoalesced","matMul_gpu", "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem",
          "matrix_sum_normal", "matrix_sum_coalesced", 
          "dotProd", "vectorAdd",  "subSeqMax")


DataAppGPU30 <- read.csv(file = "./R-code/Datasets/AppGPU30.csv")
DataAppGPU35 <- read.csv(file = "./R-code/Datasets/AppGPU35.csv")
DataAppGPU50 <- read.csv(file = "./R-code/Datasets/AppGPU50.csv")
DataAppGPU52 <- read.csv(file = "./R-code/Datasets/AppGPU50.csv")





METRICS_3X <- c(
"Shared.Memory.Replay.Overhead", "Global.Memory.Replay.Overhead", "Instruction.Replay.Overhead", 
"L2.Throughput..L1.Reads.", "L2.Hit.Rate..L1.Reads.", "L2.Read.Transactions", "L2.Write.Transactions", "L2.Throughput..Reads.","L2.Throughput..Writes.", 
"L2.Read.Transactions..L1.read.requests.", "L2.Write.Transactions..L1.write.requests.",
"Instructions.per.warp", 
"Global.Load.Transactions", "Global.Load.Transactions.Per.Request", 
"Issued.Control.Flow.Instructions", "Executed.Control.Flow.Instructions", "Issued.Load.Store.Instructions", "Executed.Load.Store.Instructions", 
"Floating.Point.Operations.Single.Precision.", "Floating.Point.Operations.Single.Precision.Add.","Floating.Point.Operation.Single.Precision.Mul.","FP.Instructions.Single.",
"Floating.Point.Operations.Single.Precision.FMA.","FLOP.Efficiency.Peak.Single.", 
"Instructions.Executed",	"Instructions.Issued",	"Issue.Slots", "Control.Flow.Instructions", "Misc.Instructions", "ECC.Transactions")

EVENTS_3X <- c("l2_subp0_total_read_sector_queries",	"l2_subp1_total_read_sector_queries",	"l2_subp2_total_read_sector_queries",	
            "l2_subp3_total_read_sector_queries",	"l2_subp0_total_write_sector_queries",	"l2_subp1_total_write_sector_queries",	
            "l2_subp2_total_write_sector_queries",	"l2_subp3_total_write_sector_queries",	"elapsed_cycles_sm",	
            "gld_inst_8bit",	"gld_inst_16bit",	"gld_inst_32bit",	"gld_inst_64bit",	"gld_inst_128bit",	'gst_inst_8bit',	
            "gst_inst_16bit",	"gst_inst_32bit",	"gst_inst_64bit",	"gst_inst_128bit","threads_launched","gld_request",	"gst_request",
            "sm_cta_launched", "uncached_global_load_transaction",	"global_store_transaction",
            "X__l1_global_load_transactions",	"X__l1_global_store_transactions")



par3X <- DataAppGPU3X[,c("Achieved.Occupancy", "Executed.IPC", "Global.Store.Transactions.Per.Request", "Global.Store.Transactions", 
                         "Device.Memory.Read.Transactions", "L2.Write.Transactions", "warps_launched", "inst_executed","inst_issued2",
                         "Block.X", "Block.Y", "Grid.X", "Grid.Y", "Registers.Per.Thread", "Static.SMem" )]



Duration <- par3X5X[,"Duration"]

par3X5X[,"Duration"] <- NULL


pc <- prcomp(par3X5X)

Model <- lm(Duration~pc$x[,1]+pc$x[,2])
predict()

plot(pc)
