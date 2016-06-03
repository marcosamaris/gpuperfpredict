library(randomForest)
library(ggplot2)


dirpath <- "~/Doctorate/svm-gpuperf/"
setwd(paste(dirpath, sep=""))

gpus <- read.table("./R-code/deviceInfo.csv", sep=",", header=T)
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

Parameters_3x <- c("GpuName","GpuId", "L2", "Bus", "Memoryclock", "AppName", "AppId",  "Input.Size","Duration","Issued.IPC",	"Instructions.per.warp",	"Issue.Slot.Utilization",
                   "Shared.Memory.Load.Transactions.Per.Request",	"Shared.Memory.Store.Transactions.Per.Request",
                   "Global.Load.Transactions.Per.Request",	"Global.Store.Transactions.Per.Request",
                   "Shared.Load.Transactions",	"Shared.Store.Transactions", "Global.Load.Transactions",	"Global.Store.Transactions",
                   "Device.Memory.Read.Transactions",	"Device.Memory.Write.Transactions", "L2.Read.Transactions",	"L2.Write.Transactions",
                   "Issued.Control.Flow.Instructions",	"Executed.Control.Flow.Instructions",	"Issued.Load.Store.Instructions",	"Executed.Load.Store.Instructions",
                   "Floating.Point.Operations.Single.Precision.", "Floating.Point.Operations.Single.Precision.FMA.","Instructions.Executed",	"Instructions.Issued",
                   "Issue.Slots","FP.Instructions.Single.", "Control.Flow.Instructions", "Misc.Instructions", "L2.Read.Transactions..L1.read.requests.", "L2.Write.Transactions..L1.write.requests.",
                   "ECC.Transactions", "Eligible.Warps.Per.Active.Cycle", "FLOP.Efficiency.Peak.Single.","fb_subp0_read_sectors",	"fb_subp1_read_sectors",	"fb_subp0_write_sectors",	"fb_subp1_write_sectors", "warps_launched",	
                   "threads_launched",	"inst_executed",	"inst_issued1",	"inst_issued2","gld_inst_32bit", "gst_inst_32bit", "gld_request",	"gst_request", "Grid.X", "Block.X")

Parameters_5x <- c("GpuName","GpuId", "L2", "Bus", "Memoryclock", "AppName", "AppId", "Input.Size", "Duration","Issued.IPC",	"Instructions.per.warp",	"Issue.Slot.Utilization",
                   "Shared.Memory.Load.Transactions.Per.Request",	"Shared.Memory.Store.Transactions.Per.Request",
                   "Global.Load.Transactions.Per.Request",	"Global.Store.Transactions.Per.Request",
                   "Shared.Load.Transactions",	"Shared.Store.Transactions", "Global.Load.Transactions",	"Global.Store.Transactions",
                   "Device.Memory.Read.Transactions",	"Device.Memory.Write.Transactions", "L2.Read.Transactions",	"L2.Write.Transactions",
                   "Global.Hit.Rate",
                   "Issued.Control.Flow.Instructions",	"Executed.Control.Flow.Instructions",	"Issued.Load.Store.Instructions",	"Executed.Load.Store.Instructions",
                   "Floating.Point.Operations.Single.Precision.", "Floating.Point.Operations.Single.Precision.FMA.","Instructions.Executed",	"Instructions.Issued",
                   "Issue.Slots","FP.Instructions.Single.", "Control.Flow.Instructions", "Misc.Instructions",
                   "Eligible.Warps.Per.Active.Cycle", "FLOP.Efficiency.Peak.Single.","fb_subp0_read_sectors",	"fb_subp1_read_sectors",	"fb_subp0_write_sectors",	"fb_subp1_write_sectors", "warps_launched",	
                   "inst_executed",	"inst_issued1",	"inst_issued2","gld_inst_32bit", "gst_inst_32bit", "Grid.X", "Block.X")

# Those parameters are always 0 in CC 3.5  and 5.2
# Local.Memory.Load.Transactions.Per.Request
# Local.Memory.Store.Transactions.Per.Request
# Local.Load.Transactions
# Local.Store.Transactions
# 
# Those parameters are not in CC 5.2 or they are always 0
#     L2.Read.Transactions..L1.read.requests.
#     L2.Write.Transactions..L1.write.requests.
#     ECC.Transactions
#     threads_launched
#     gld_request
#     gst_request

DataAppGPU30 <- read.csv(file = paste("./R-code/Datasets/AppGPU30.csv", sep = ""))
DataAppGPU35 <- read.csv(file = paste("./R-code/Datasets/AppGPU35.csv", sep = ""))
DataAppGPU50 <- read.csv(file = paste("./R-code/Datasets/AppGPU50.csv", sep = ""))
DataAppGPU52 <- read.csv(file = paste("./R-code/Datasets/AppGPU52.csv", sep = ""))


result <- data.frame()
# write.csv(Data, file = "./R-code/Datasets/CleanData/App-GPU-CC-5X.csv")
for (CC in c(3,5)){
    if (CC == 3 ){
        DataAppGPU <- rbind(DataAppGPU30[Parameters_3x], DataAppGPU35[Parameters_3x])
    } else {
        DataAppGPU <- rbind(DataAppGPU50[Parameters_5x],DataAppGPU52[Parameters_5x])
    }
    for( j in 1:9) {
    
        
        Data <- subset(DataAppGPU, AppId == j )
        Data <- Data[complete.cases(Data),]
        dim(Data)
        # View(Data)
        # summary(Data)
        # DataAppGPU35 <- DataAppGPU35[sapply(DataAppGPU35,is.numeric)]
        # DataAppGPU35 <- DataAppGPU35[,-(which(colSums(DataAppGPU35) == 0))]
        # 
        
        if (j < 5) {
            lowerLimit <- 2048
            uperLimit <- 4096
            blockSize <- 16
        } else if (j >= 5 & j < 7) {
            lowerLimit <- 4096
            uperLimit <- 5376
            blockSize <- 16
        } else {
            lowerLimit <- 50331648
            uperLimit <- 71303168
            blockSize <- 256
        }

         if (j < 9) {
            trainingSet <- subset(Data, Input.Size <= lowerLimit | Input.Size >= uperLimit | Block.X != blockSize)
            testSet <- subset(Data, (Input.Size > lowerLimit & Input.Size < uperLimit) & Block.X == blockSize)
            dim(trainingSet)
            dim(testSet)
         } else {
            trainingSet <- subset(Data, Input.Size <= lowerLimit | Input.Size >= uperLimit)
            testSet <- subset(Data, (Input.Size > lowerLimit & Input.Size < uperLimit))
         }
        
        trainingSet$AppName <- NULL
        trainingSet$GpuName <- NULL
        trainingSet$GpuId <- NULL
        # trainingDuration <- trainingSet["Duration"]
        # trainingSet$Duration <- NULL
        dim(trainingSet)
        
        TestDuration <- testSet["Duration"]
        Size <- testSet["Input.Size"]
        App <- testSet["AppName"]
        Gpu <- testSet["GpuName"]
        Block <- testSet["Block.X"]
        
        testSet$AppName <- NULL
        testSet$GpuName <- NULL
        testSet$GpuId <- NULL
        testSet$Duration <- NULL
        dim(testSet)
        
        fit <- randomForest(trainingSet$Duration ~ ., data = trainingSet,mtry = 2, importance = TRUE,do.trace = 100)
        print(fit)
        summary(fit)
        predictions <- predict(fit, testSet)
        
        mse <- mean((as.matrix(TestDuration)  - predictions)^2)
        mae <- mean(abs(as.matrix(TestDuration)  - predictions))
        mape <- mean(abs(as.matrix(TestDuration)  - predictions/predictions))
        # mpe <- mean(as.matrix(TestDuration)  - predictions/predictions)
        # smape = mean((abs(as.matrix(predictions)  -TestDuration)/ (abs(TestDuration) + abs(predictions))/2 ))
        
        Acc <- predictions/TestDuration
        AccMin <- min(Acc)
        AccMean <- mean(as.matrix(Acc))
        AccMedian <- median(as.matrix(Acc))
        AccMax <- max(Acc)
        AccSD <- sd(as.matrix(Acc))
        
        Tempresult <- data.frame(Gpu, App, Size, Block, TestDuration, predictions, Acc, AccMin, AccMax, AccMean, AccMedian, AccSD,mse, mae,mape)
        
        result <- rbind(result, Tempresult)
        
    }
}
result
colnames(result) <-c("Gpus", "Apps", "InputSize", "ThreadBlock" , "Measured", "Predicted",  "accuracy", "Min", "max", "Mean", "Median", "SD", "mse", "mae", "mape")
write.csv(result, file = "./R-code/Results/LinearRegression.csv")

Tempresult <- data.frame(Gpu, App, Size, Block, TestDuration, predictions, Acc, AccMin, AccMax, AccMean, AccMedian, AccSD, mse, mae,mape)

result$Apps <- factor(result$Apps, levels =  c("matMul_gpu_uncoalesced","matMul_gpu", "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem",
                                               "matrix_sum_normal", "matrix_sum_coalesced", 
                                               "dotProd", "vectorAdd",  "subSeqMax"))

# result[result$Apps %in% "matrix_sum_normal" & result$Gpus %in% c("Quadro", "TitanX"),]

Graph <- ggplot(data=result, aes(x=Gpus, y=accuracy, group=Gpus, shape=Gpus,col=Gpus)) + 
    geom_boxplot(aes(shape=Gpus)) +
    xlab("GPUs") + 
    ylab(expression(paste("Accuracy ",T[k]/T[m] ))) +
    theme(axis.title = element_text(family = "Times", face="bold", size=22)) +
    theme(axis.text  = element_text(family = "Times", face="bold", size=10)) +
    theme(axis.text.x=element_blank()) +
    theme(legend.title  = element_text(family = "Times", face="bold", size=16)) +
    theme(legend.text  = element_text(family = "Times", face="bold", size=16)) +
    # facet_grid(.~Apps, scales="fixed") 
    facet_wrap(~Apps, ncol=3, scales="free_y") 
# scale_colour_grey()
Graph

ggsave(paste("./images/ResultRandomForest.pdf",sep=""), Graph, device = pdf, height=10, width=16)
ggsave(paste("./images/ResultRandomForest.png",sep=""), Graph, height=10, width=16)
