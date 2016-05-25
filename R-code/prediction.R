library(e1071)


dirpath <- "~/Doctorate/svm-gpuperf/"
setwd(paste(dirpath, sep=""))

gpus <- read.table("./ML-model/deviceInfo_L1disabled.csv", sep=",", header=T)
NoGPU <- dim(gpus)[1]

apps <- c("matMul_gpu_uncoalesced","matMul_gpu", "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem",
          "matrix_sum_normal", "matrix_sum_coalesced", 
          "dotProd", "vectorAdd",  "subSeqMax")

# METRICS_3X <- c(
# "Shared.Memory.Replay.Overhead", "Global.Memory.Replay.Overhead", "Instruction.Replay.Overhead", 
# "L2.Throughput..L1.Reads.", "L2.Hit.Rate..L1.Reads.", "L2.Read.Transactions", "L2.Write.Transactions", "L2.Throughput..Reads.","L2.Throughput..Writes.", 
# "L2.Read.Transactions..L1.read.requests.", "L2.Write.Transactions..L1.write.requests.",
# "Instructions.per.warp", 
# "Global.Load.Transactions", "Global.Load.Transactions.Per.Request", 
# "Issued.Control.Flow.Instructions", "Executed.Control.Flow.Instructions", "Issued.Load.Store.Instructions", "Executed.Load.Store.Instructions", 
# "Floating.Point.Operations.Single.Precision.", "Floating.Point.Operations.Single.Precision.Add.","Floating.Point.Operation.Single.Precision.Mul.","FP.Instructions.Single.",
# "Floating.Point.Operations.Single.Precision.FMA.","FLOP.Efficiency.Peak.Single.", 
# "Instructions.Executed",	"Instructions.Issued",	"Issue.Slots", "Control.Flow.Instructions", "Misc.Instructions", "ECC.Transactions")
# 
# EVENTS_3X <- c("l2_subp0_total_read_sector_queries",	"l2_subp1_total_read_sector_queries",	"l2_subp2_total_read_sector_queries",	
#             "l2_subp3_total_read_sector_queries",	"l2_subp0_total_write_sector_queries",	"l2_subp1_total_write_sector_queries",	
#             "l2_subp2_total_write_sector_queries",	"l2_subp3_total_write_sector_queries",	"elapsed_cycles_sm",	
#             "gld_inst_8bit",	"gld_inst_16bit",	"gld_inst_32bit",	"gld_inst_64bit",	"gld_inst_128bit",	'gst_inst_8bit',	
#             "gst_inst_16bit",	"gst_inst_32bit",	"gst_inst_64bit",	"gst_inst_128bit","threads_launched","gld_request",	"gst_request",
#             "sm_cta_launched", "uncached_global_load_transaction",	"global_store_transaction",
#             "X__l1_global_load_transactions",	"X__l1_global_store_transactions")
# 
# 
# 
# par3X <- c("Duration", "Achieved.Occupancy", "Executed.IPC", "Global.Store.Transactions.Per.Request", "Global.Store.Transactions", 
#                          "Device.Memory.Read.Transactions", "L2.Write.Transactions", "warps_launched", "inst_executed","inst_issued2",
#                          "Block.X", "Block.Y", "Grid.X", "Grid.Y", "Registers.Per.Thread", "Static.SMem" )
# 
# DataAppGPU30 <- read.csv(file = "./R-code/Datasets/AppGPU30.csv")
# DataAppGPU35 <- read.csv(file = "./R-code/Datasets/AppGPU35.csv")
# DataAppGPU50 <- read.csv(file = "./R-code/Datasets/AppGPU50.csv")
# DataAppGPU52 <- read.csv(file = "./R-code/Datasets/AppGPU52.csv")

Parameters_35 <- c("AppName", "Input.Size","Duration","Issued.IPC",	"Instructions.per.warp",	"Issue.Slot.Utilization",	"Local.Memory.Load.Transactions.Per.Request",
         "Local.Memory.Store.Transactions.Per.Request",	"Shared.Memory.Load.Transactions.Per.Request",	"Shared.Memory.Store.Transactions.Per.Request",
         "Global.Load.Transactions.Per.Request",	"Global.Store.Transactions.Per.Request",	"Local.Load.Transactions",
         "Local.Store.Transactions",	"Shared.Load.Transactions",	"Shared.Store.Transactions",	"Global.Load.Transactions",	"Global.Store.Transactions",
         "Device.Memory.Read.Transactions",	"Device.Memory.Write.Transactions", "L2.Read.Transactions",	"L2.Write.Transactions",
         "Issued.Control.Flow.Instructions",	"Executed.Control.Flow.Instructions",	"Issued.Load.Store.Instructions",	"Executed.Load.Store.Instructions",
         "Floating.Point.Operations.Single.Precision.", "Floating.Point.Operations.Single.Precision.FMA.","Instructions.Executed",	"Instructions.Issued",
         "Issue.Slots","FP.Instructions.Single.", "Control.Flow.Instructions", "Misc.Instructions", "L2.Read.Transactions..L1.read.requests.", "L2.Write.Transactions..L1.write.requests.",
         "ECC.Transactions", "FLOP.Efficiency.Peak.Single.","fb_subp0_read_sectors",	"fb_subp1_read_sectors",	"fb_subp0_write_sectors",	"fb_subp1_write_sectors", "warps_launched",	
                "threads_launched",	"inst_executed",	"inst_issued1",	"inst_issued2","gld_request",	"gst_request", "Grid.X", "Block.X")

length(Parameters_35)
DataAppGPU35 <- read.csv(file = "./R-code/Datasets/AppGPU35.csv")
dim(DataAppGPU35)

Data <- subset(DataAppGPU35, AppId < 5)

Data <- Data[Parameters_35]
Data <- Data[complete.cases(Data),]
dim(Data)
# summary(Data)

# DataAppGPU35 <- DataAppGPU35[sapply(DataAppGPU35,is.numeric)]
# DataAppGPU35 <- DataAppGPU35[,-(which(colSums(DataAppGPU35) == 0))]
# 
trainingSet <- subset(Data, Input.Size < 4096 | Input.Size < 5376)
trainingSet$AppName <- NULL
# trainingDuration <- trainingSet["Duration"]
# trainingSet$Duration <- NULL
dim(trainingSet)

testSet <- subset(Data, Input.Size > 4096 & Input.Size < 5376)
TestDuration <- testSet["Duration"]
Size <- testSet["Input.Size"]
App <- testSet["AppName"]
Block <- testSet["Block.X"]

testSet$AppName <- NULL
testSet$Duration <- NULL
dim(testSet)

base <- lm(trainingSet$Duration ~ ., data = trainingSet) 
summary(base)
fit <- step(base)
summary(fit)
predictions <- predict(fit, testSet)

rmse <- mean((TestDuration  - predictions)^2)
print(rmse)

result <- data.frame(App, Size, Block, TestDuration, predictions)
colnames(result) <-c("Apps", "InputSize", "ThreadBlock" , "Measured", "Predicted")
result$Apps <- factor(result$Apps, levels =  c("matMul_gpu_uncoalesced","matMul_gpu", "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem",
                                                   "matrix_sum_normal", "matrix_sum_coalesced", 
                                                   "dotProd", "vectorAdd",  "subSeqMax"))

result
# library(ggplot2)
pl <- ggplot(data=result, aes(x=InputSize, y=Predicted, group=Apps, shape=Apps))  + geom_point(col="red",aes(shape=Apps)) + 
    geom_point(data = result,aes(x=InputSize, y=Measured, group=Apps, shape=Apps),col="blue") +
    facet_grid(ThreadBlock~Apps, scales="fixed") 
pl


                
