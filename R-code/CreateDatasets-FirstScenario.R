library(zoo)

dirpath <- "~/Doctorate/svm-gpuperf/"
setwd(paste(dirpath, sep=""))

gpus <- read.table("./R-code/deviceInfo.csv", sep=",", header=T)
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

AppGPUInfoAll30 <- data.frame()
AppGPUInfoAll35 <- data.frame()
AppGPUInfoAll50 <- data.frame()
AppGPUInfoAll52 <- data.frame()

k <- 4
for (i in 1:NoGPU){
    GPUAppTemp <- data.frame()
    metricsTemp<- NULL
    eventsTemp <- NULL
    tracesTemp <- NULL
    for (j in c(4, 8, 12, 16, 20, 24, 28, 32)){
        if (gpus[i,'compute_version'] == 3.0){
                metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics30), 
                                        stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents30), 
                                       stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                       stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                
                print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                GPUAppTemp <- cbind(gpus[i,],AppName=apps[k], AppId=k, metricsTemp, eventsTemp[,-1], tracesTemp[,-1][1:11])

            
            AppGPUInfoAll30 <- rbind(AppGPUInfoAll30, GPUAppTemp)
        } else if (gpus[i,'compute_version'] == 3.5) {
                metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics35), 
                                        stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents35), 
                                       stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                       stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                
                
                
                print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                GPUAppTemp <- cbind(gpus[i,],AppName=apps[k], AppId=k, metricsTemp, eventsTemp[,-1], tracesTemp[,-1][1:11])
           
            
            AppGPUInfoAll35 <- rbind(AppGPUInfoAll35, GPUAppTemp)
            
        } else if (gpus[i,'compute_version'] == 5.0){
                metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics50), 
                                        stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents50), 
                                       stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                       stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                
                
                print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                GPUAppTemp <- cbind(gpus[i,],AppName=apps[k], AppId=k, metricsTemp, eventsTemp[,-1], tracesTemp[,-1][1:11])
            
            AppGPUInfoAll50 <- rbind(AppGPUInfoAll50, GPUAppTemp)
        } else if (gpus[i,'compute_version'] == 5.2) {
            if (j == 24 & i == 10){
             print(j)   
            } else {
                metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics52), 
                                        stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents52), 
                                       stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                       stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))

                
                print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                GPUAppTemp <- cbind(gpus[i,],AppName=apps[k], AppId=k, metricsTemp, eventsTemp[,-1], tracesTemp[,-1][1:11])
           
            AppGPUInfoAll52 <- rbind(AppGPUInfoAll52, GPUAppTemp)
            }
        }
        
    }

}




Parameters_3x <- c("gpu_name","gpu_id", "AppName", "AppId", "Input.Size", "Duration", 
                   "max_clock_rate",	"num_of_cores",	"L2",	"bus",	"memory_clock",	"bandwith",
                   "Achieved.Occupancy",
                   "Global.Load.Transactions.Per.Request", "gld_request",
                   "Global.Store.Transactions.Per.Request", "gst_request",
                   "shared_load",	"shared_store",
                   "Shared.Memory.Load.Transactions.Per.Request",	"Shared.Memory.Store.Transactions.Per.Request",
                   "inst_issued2",
                   "Device.Memory.Read.Transactions",	"Device.Memory.Write.Transactions",	"L2.Read.Transactions",	"L2.Write.Transactions",
                   "warps_launched",
                   "Grid.X",	"Grid.Y",	"Block.X",	"Block.Y",	"Registers.Per.Thread",	"Static.SMem"
)

Parameters_5x <- c("gpu_name","gpu_id", "AppName", "AppId", "Input.Size", "Duration", 
                   "max_clock_rate",	"num_of_cores",	"L2",	"bus",	"memory_clock",	"bandwith",
                   "Achieved.Occupancy",
                   "Global.Load.Transactions.Per.Request", "global_load",
                   "Global.Store.Transactions.Per.Request", "global_store",
                   "shared_load",	"shared_store",
                   "Shared.Memory.Load.Transactions.Per.Request",	"Shared.Memory.Store.Transactions.Per.Request",
                   "inst_issued2",
                   "Device.Memory.Read.Transactions",	"Device.Memory.Write.Transactions",	"L2.Read.Transactions",	"L2.Write.Transactions",
                   "warps_launched",
                   "Grid.X",	"Grid.Y",	"Block.X",	"Block.Y",	"Registers.Per.Thread",	"Static.SMem"
)
length(Parameters_3x)
length(Parameters_5x)

DataAppGPU30 <- AppGPUInfoAll30
DataAppGPU35 <- AppGPUInfoAll35
DataAppGPU50 <- AppGPUInfoAll50
DataAppGPU52 <- AppGPUInfoAll52


DataAppGPU30$Global.Load.Transactions.Per.Request <- na.locf(DataAppGPU30$Global.Load.Transactions.Per.Request)
DataAppGPU35$Global.Load.Transactions.Per.Request <- na.locf(DataAppGPU35$Global.Load.Transactions.Per.Request)
DataAppGPU50$Global.Load.Transactions.Per.Request <- na.locf(DataAppGPU50$Global.Load.Transactions.Per.Request)
DataAppGPU52$Global.Load.Transactions.Per.Request <- na.locf(DataAppGPU52$Global.Load.Transactions.Per.Request)

DataAppGPU30$Achieved.Occupancy <- na.locf(DataAppGPU30$Achieved.Occupancy)
DataAppGPU35$Achieved.Occupancy <- na.locf(DataAppGPU35$Achieved.Occupancy)
DataAppGPU50$Achieved.Occupancy <- na.locf(DataAppGPU50$Achieved.Occupancy)
DataAppGPU52$Achieved.Occupancy <- na.locf(DataAppGPU52$Achieved.Occupancy)

DataAppGPU30 <- DataAppGPU30[c(Parameters_3x,"Floating.Point.Operations.Single.Precision.")]
DataAppGPU35 <- DataAppGPU35[c(Parameters_3x,"Floating.Point.Operations.Single.Precision.")]
DataAppGPU50 <- DataAppGPU50[c(Parameters_5x,"Floating.Point.Operations.Single.Precision.")]
DataAppGPU52 <- DataAppGPU52[c(Parameters_5x,"FP.Instructions.Single.")]

colnames(DataAppGPU50)[which(names(DataAppGPU50) == "global_load")] <- "gld_request"
colnames(DataAppGPU50)[which(names(DataAppGPU50) == "global_store")] <- "gst_request"

colnames(DataAppGPU52)[which(names(DataAppGPU52) == "global_load")] <- "gld_request"
colnames(DataAppGPU52)[which(names(DataAppGPU52) == "global_store")] <- "gst_request"
colnames(DataAppGPU52)[which(names(DataAppGPU52) == "FP.Instructions.Single.")] <- "Floating.Point.Operations.Single.Precision."

DataAppGPU30 <- cbind(DataAppGPU30, 
                      totalLoadGM=DataAppGPU30$gld_request/DataAppGPU30$Global.Load.Transactions.Per.Request, 
                      totalStoreGM=DataAppGPU30$gst_request/DataAppGPU30$Global.Store.Transactions.Per.Request,
                      totalLoadSM=DataAppGPU30$shared_load/DataAppGPU30$Shared.Memory.Load.Transactions.Per.Request,
                      totalStoreSM=DataAppGPU30$shared_store/DataAppGPU30$Shared.Memory.Store.Transactions.Per.Request,
                      blockSize=DataAppGPU30$Block.X*DataAppGPU30$Block.Y,
                      GridSize=DataAppGPU30$Grid.X*DataAppGPU30$Grid.Y,
                      totalThreads=DataAppGPU30$Block.X*DataAppGPU30$Block.Y*DataAppGPU30$Grid.X*DataAppGPU30$Grid.Y)

DataAppGPU35 <- cbind(DataAppGPU35, 
                      totalLoadGM=DataAppGPU35$gld_request/DataAppGPU35$Global.Load.Transactions.Per.Request, 
                      totalStoreGM=DataAppGPU35$gst_request/DataAppGPU35$Global.Store.Transactions.Per.Request,
                      totalLoadSM=DataAppGPU35$shared_load/DataAppGPU35$Shared.Memory.Load.Transactions.Per.Request,
                      totalStoreSM=DataAppGPU35$shared_store/DataAppGPU35$Shared.Memory.Store.Transactions.Per.Request,
                      blockSize=DataAppGPU35$Block.X*DataAppGPU35$Block.Y,
                      GridSize=DataAppGPU35$Grid.X*DataAppGPU35$Grid.Y,
                      totalThreads=DataAppGPU35$Block.X*DataAppGPU35$Block.Y*DataAppGPU35$Grid.X*DataAppGPU35$Grid.Y)


DataAppGPU50 <- cbind(DataAppGPU50, 
                      totalLoadGM=DataAppGPU50$gld_request/DataAppGPU50$Global.Load.Transactions.Per.Request, 
                      totalStoreGM=DataAppGPU50$gst_request/DataAppGPU50$Global.Store.Transactions.Per.Request,
                      totalLoadSM=DataAppGPU50$shared_load/DataAppGPU50$Shared.Memory.Load.Transactions.Per.Request,
                      totalStoreSM=DataAppGPU50$shared_store/DataAppGPU50$Shared.Memory.Store.Transactions.Per.Request,
                      blockSize=DataAppGPU50$Block.X*DataAppGPU50$Block.Y,
                      GridSize=DataAppGPU50$Grid.X*DataAppGPU50$Grid.Y,
                      totalThreads=DataAppGPU50$Block.X*DataAppGPU50$Block.Y*DataAppGPU50$Grid.X*DataAppGPU50$Grid.Y)

DataAppGPU52 <- cbind(DataAppGPU52, 
                      totalLoadGM=DataAppGPU52$gld_request/DataAppGPU52$Global.Load.Transactions.Per.Request, 
                      totalStoreGM=DataAppGPU52$gst_request/DataAppGPU52$Global.Store.Transactions.Per.Request,
                      totalLoadSM=DataAppGPU52$shared_load/DataAppGPU52$Shared.Memory.Load.Transactions.Per.Request,
                      totalStoreSM=DataAppGPU52$shared_store/DataAppGPU52$Shared.Memory.Store.Transactions.Per.Request,
                      blockSize=DataAppGPU52$Block.X*DataAppGPU52$Block.Y,
                      GridSize=DataAppGPU52$Grid.X*DataAppGPU52$Grid.Y,
                      totalThreads=DataAppGPU52$Block.X*DataAppGPU52$Block.Y*DataAppGPU52$Grid.X*DataAppGPU52$Grid.Y)


write.csv(rbind(DataAppGPU30,DataAppGPU35,DataAppGPU50,DataAppGPU52), file = "./R-code/Datasets/CleanData/matMul_gpu_sharedmem-All.csv")

