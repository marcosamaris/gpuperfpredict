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
for (i in 1:NoGPU){
    
    for (k in 1:length(apps)){
        GPUAppTemp <- data.frame()
        metricsTemp<- NULL
        eventsTemp <- NULL
        tracesTemp <- NULL
        for (j in c(8, 16, 32)){
            if (gpus[i,'compute_version'] == 3.0){
                if( apps[k] != "subSeqMax"){
                    
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics30), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents30), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    # temp <- 0; data <- matrix()
                    # for(r in 1:10){
                    #         temp <- read.table(paste("./data/", gpus[i,'gpu_name'],"/traces_",j,"/run_", r-1, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F)["V3"]
                    #         data[[r]] <- temp
                    # }
                    # 
                    # DimTemp <- dim(tracesTemp)[1]
                    # temp <- array();
                    # Durationtemp <- array();
                    # for (s in 1:DimTemp){
                    #     for(r in 1:10){
                    #         temp[[r]] <- data[[r]]["V3"][s,]
                    #     }
                    #     print(try(t.test(temp, alternative = "two.sided", conf.level = 0.95)))
                    #     Durationtemp[s] <- sum(temp)/10
                    # }
                    # tracesTemp$Duration <- Durationtemp
                    
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(gpus[i,],AppName=apps[k], AppId=k, metricsTemp, eventsTemp[,-1], tracesTemp[,-1][1:11])
                    AppGPUInfoAll30 <- rbind(AppGPUInfoAll30, GPUAppTemp)
                } else if (j == 16) {
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics30), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents30), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    # temp <- 0; data <- matrix()
                    # for(r in 1:10){
                    #     temp <- read.table(paste("./data/", gpus[i,'gpu_name'],"/traces_",j,"/run_", r-1, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F)["V3"]
                    #     data[[r]] <- temp
                    # }
                    # 
                    # DimTemp <- dim(tracesTemp)[1]
                    # temp <- array();
                    # Durationtemp <- array();
                    # for (s in 1:DimTemp){
                    #     for(r in 1:10){
                    #         temp[[r]] <- data[[r]]["V3"][s,]
                    #     }
                    #     print(try(t.test(temp, alternative = "two.sided", conf.level = 0.95)))
                    #     Durationtemp[s] <- sum(temp)/10
                    # }
                    # tracesTemp$Duration <- Durationtemp
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(gpus[i,],AppName=apps[k], AppId=k, metricsTemp, eventsTemp[,-1], tracesTemp[,-1][1:11])
                    AppGPUInfoAll30 <- rbind(AppGPUInfoAll30, GPUAppTemp)
                }
                
                
            } else if (gpus[i,'compute_version'] == 3.5) {
                if(apps[k] != "subSeqMax"){
                    
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics35), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents35), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(gpus[i,],AppName=apps[k], AppId=k, metricsTemp, eventsTemp[,-1], tracesTemp[,-1][1:11])
                    AppGPUInfoAll35 <- rbind(AppGPUInfoAll35, GPUAppTemp)
                } else if (j == 16) {
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics35), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents35), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    # temp <- 0; data <- matrix()
                    # for(r in 1:10){
                    #     temp <- read.table(paste("./data/", gpus[i,'gpu_name'],"/traces_",j,"/run_", r-1, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F)["V3"]
                    #     data[[r]] <- temp
                    # }
                    # 
                    # DimTemp <- dim(tracesTemp)[1]
                    # temp <- array();
                    # Durationtemp <- array();
                    # for (s in 1:DimTemp){
                    #     for(r in 1:10){
                    #         temp[[r]] <- data[[r]]["V3"][s,]
                    #     }
                    #     print(try(t.test(temp, alternative = "two.sided", conf.level = 0.95)))
                    #     Durationtemp[s] <- sum(temp)/10
                    # }
                    # tracesTemp$Duration <- Durationtemp
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(gpus[i,],AppName=apps[k], AppId=k, metricsTemp, eventsTemp[,-1], tracesTemp[,-1][1:11])
                    AppGPUInfoAll35 <- rbind(AppGPUInfoAll35, GPUAppTemp)
                }
                
                
            } else if (gpus[i,'compute_version'] == 5.0){
                if( apps[k] != "subSeqMax"){
                    
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics50), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents50), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    # temp <- 0; data <- matrix()
                    # for(r in 1:10){
                    #     temp <- read.table(paste("./data/", gpus[i,'gpu_name'],"/traces_",j,"/run_", r-1, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F)["V3"]
                    #     data[[r]] <- temp
                    # }
                    # 
                    # DimTemp <- dim(tracesTemp)[1]
                    # temp <- array();
                    # Durationtemp <- array();
                    # for (s in 1:DimTemp){
                    #     for(r in 1:10){
                    #         temp[[r]] <- data[[r]]["V3"][s,]
                    #     }
                    #     print(try(t.test(temp, alternative = "two.sided", conf.level = 0.95)))
                    #     Durationtemp[s] <- sum(temp)/10
                    # }
                    # tracesTemp$Duration <- Durationtemp
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(gpus[i,],AppName=apps[k], AppId=k, metricsTemp, eventsTemp[,-1], tracesTemp[,-1][1:11])
                    AppGPUInfoAll50 <- rbind(AppGPUInfoAll50, GPUAppTemp)
                } else if (j == 16) {
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics50), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents50), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    # temp <- 0; data <- matrix()
                    # for(r in 1:10){
                    #     temp <- read.table(paste("./data/", gpus[i,'gpu_name'],"/traces_",j,"/run_", r-1, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F)["V3"]
                    #     data[[r]] <- temp
                    # }
                    # 
                    # DimTemp <- dim(tracesTemp)[1]
                    # temp <- array();
                    # Durationtemp <- array();
                    # for (s in 1:DimTemp){
                    #     for(r in 1:10){
                    #         temp[[r]] <- data[[r]]["V3"][s,]
                    #     }
                    #     print(try(t.test(temp, alternative = "two.sided", conf.level = 0.95)))
                    #     Durationtemp[s] <- sum(temp)/10
                    # }
                    # tracesTemp$Duration <- Durationtemp
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(gpus[i,],AppName=apps[k], AppId=k, metricsTemp, eventsTemp[,-1], tracesTemp[,-1][1:11])
                    AppGPUInfoAll50 <- rbind(AppGPUInfoAll50, GPUAppTemp)
                }
                
            } else if (gpus[i,'compute_version'] == 5.2) {
                if(apps[k] != "subSeqMax"){
                    
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics52), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents52), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    # temp <- 0; data <- matrix()
                    # for(r in 1:10){
                    #     temp <- read.table(paste("./data/", gpus[i,'gpu_name'],"/traces_",j,"/run_", r-1, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F)["V3"]
                    #     data[[r]] <- temp
                    # }
                    # 
                    # DimTemp <- dim(tracesTemp)[1]
                    # temp <- array();
                    # Durationtemp <- array();
                    # for (s in 1:DimTemp){
                    #     for(r in 1:10){
                    #         temp[[r]] <- data[[r]]["V3"][s,]
                    #     }
                    #     print(try(t.test(temp, alternative = "two.sided", conf.level = 0.95)))
                    #     Durationtemp[s] <- sum(temp)/10
                    # }
                    # tracesTemp$Duration <- Durationtemp
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(gpus[i,],AppName=apps[k], AppId=k, metricsTemp, eventsTemp[,-1], tracesTemp[,-1][1:11])
                    AppGPUInfoAll52 <- rbind(AppGPUInfoAll52, GPUAppTemp)
                } else if (j == 16) {
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics52), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents52), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    # temp <- 0; data <- matrix()
                    # for(r in 1:10){
                    #     temp <- read.table(paste("./data/", gpus[i,'gpu_name'],"/traces_",j,"/run_", r-1, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F)["V3"]
                    #     data[[r]] <- temp
                    # }
                    # 
                    # DimTemp <- dim(tracesTemp)[1]
                    # temp <- array();
                    # Durationtemp <- array();
                    # for (s in 1:DimTemp){
                    #     for(r in 1:10){
                    #         temp[[r]] <- data[[r]]["V3"][s,]
                    #     }
                    #     print(try(t.test(temp, alternative = "two.sided", conf.level = 0.95)))
                    #     Durationtemp[s] <- sum(temp)/10
                    # }
                    # tracesTemp$Duration <- Durationtemp
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(gpus[i,],AppName=apps[k], AppId=k, metricsTemp, eventsTemp[,-1], tracesTemp[,-1][1:11])
                    AppGPUInfoAll52 <- rbind(AppGPUInfoAll52, GPUAppTemp)
                }
            }
        }
    }
}


write.csv(AppGPUInfoAll30, file = "./R-code/Datasets/AppGPU30.csv")
write.csv(AppGPUInfoAll35, file = "./R-code/Datasets/AppGPU35.csv")
write.csv(AppGPUInfoAll50, file = "./R-code/Datasets/AppGPU50.csv")
write.csv(AppGPUInfoAll52, file = "./R-code/Datasets/AppGPU52.csv")


##### Create Datasets for each Application
for (k in 1:length(apps)){
    write.csv(AppGPUInfoAll30[AppGPUInfoAll30["AppId"] == k,], file = paste("./R-code/Datasets/Apps/", apps[k], "-GPU30.csv", sep = ""))
}


for (k in 1:length(apps)){
    write.csv(AppGPUInfoAll35[AppGPUInfoAll35["AppId"] == k,], file = paste("./R-code/Datasets/Apps/", apps[k], "-GPU35.csv", sep = ""))
}


for (k in 1:length(apps)){
    write.csv(AppGPUInfoAll50[AppGPUInfoAll50["AppId"] == k,], file = paste("./R-code/Datasets/Apps/", apps[k], "-GPU50.csv", sep = ""))
}


for (k in 1:length(apps)){
    write.csv(AppGPUInfoAll52[AppGPUInfoAll52["AppId"] == k,], file = paste("./R-code/Datasets/Apps/", apps[k], "-GPU52.csv", sep = ""))
}


##### Create Datasets for each GPU
write.csv(AppGPUInfoAll30[AppGPUInfoAll30["gpu_id"] == 1,], file = paste("./R-code/Datasets/Gpus/", gpus[1,'gpu_name'], ".csv", sep = ""))
write.csv(AppGPUInfoAll35[AppGPUInfoAll35["gpu_id"] == 2,], file = paste("./R-code/Datasets/Gpus/", gpus[2,'gpu_name'], ".csv", sep = ""))
write.csv(AppGPUInfoAll35[AppGPUInfoAll35["gpu_id"] == 3,], file = paste("./R-code/Datasets/Gpus/", gpus[3,'gpu_name'], ".csv", sep = ""))
write.csv(AppGPUInfoAll35[AppGPUInfoAll35["gpu_id"] == 4,], file = paste("./R-code/Datasets/Gpus/", gpus[4,'gpu_name'], ".csv", sep = ""))
write.csv(AppGPUInfoAll35[AppGPUInfoAll35["gpu_id"] == 5,], file = paste("./R-code/Datasets/Gpus/", gpus[5,'gpu_name'], ".csv", sep = ""))
write.csv(AppGPUInfoAll35[AppGPUInfoAll35["gpu_id"] == 6,], file = paste("./R-code/Datasets/Gpus/", gpus[6,'gpu_name'], ".csv", sep = ""))
write.csv(AppGPUInfoAll50[AppGPUInfoAll50["gpu_id"] == 7,], file = paste("./R-code/Datasets/Gpus/", gpus[7,'gpu_name'], ".csv", sep = ""))
write.csv(AppGPUInfoAll52[AppGPUInfoAll52["gpu_id"] == 8,], file = paste("./R-code/Datasets/Gpus/", gpus[8,'gpu_name'], ".csv", sep = ""))
write.csv(AppGPUInfoAll52[AppGPUInfoAll52["gpu_id"] == 9,], file = paste("./R-code/Datasets/Gpus/", gpus[9,'gpu_name'], ".csv", sep = ""))
write.csv(AppGPUInfoAll52[AppGPUInfoAll52["gpu_id"] == 10,], file = paste("./R-code/Datasets/Gpus/", gpus[10,'gpu_name'], ".csv", sep = ""))



##### Create Datasets for each Application and each GPU
for (i in 1:NoGPU){
    if(gpus[i,'compute_version'] == 3.0){
        for (k in 1:length(apps)){
            write.csv(AppGPUInfoAll30[AppGPUInfoAll30$AppId == k & AppGPUInfoAll30$gpu_id == i,], 
                      file = paste("./R-code/Datasets/Apps-Gpus/", apps[k], "-", gpus[i,'gpu_name'], ".csv", sep = ""))
        }
    }
    
    if(gpus[i,'compute_version'] == 3.5){
        for (k in 1:length(apps)){
            write.csv(AppGPUInfoAll35[AppGPUInfoAll35$AppId == k & AppGPUInfoAll35$gpu_id == i,], 
                      file = paste("./R-code/Datasets/Apps-Gpus/", apps[k], "-", gpus[i,'gpu_name'], ".csv", sep = ""))
        }
    }
    
    if(gpus[i,'compute_version'] == 5.0){
        for (k in 1:length(apps)){
            write.csv(AppGPUInfoAll30[AppGPUInfoAll50$AppId == k & AppGPUInfoAll50$gpu_id == i,], 
                      file = paste("./R-code/Datasets/Apps-Gpus/", apps[k], "-", gpus[i,'gpu_name'], ".csv", sep = ""))
        }
    }
    
    if(gpus[i,'compute_version'] == 5.2){
        for (k in 1:length(apps)){
            write.csv(AppGPUInfoAll52[AppGPUInfoAll52$AppId == k & AppGPUInfoAll52$gpu_id == i,], 
                      file = paste("./R-code/Datasets/Apps-Gpus/", apps[k], "-", gpus[i,'gpu_name'], ".csv", sep = ""))
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

DataAppGPU30 <- read.csv(file = paste("./R-code/Datasets/AppGPU30.csv", sep = ""))
DataAppGPU35 <- read.csv(file = paste("./R-code/Datasets/AppGPU35.csv", sep = ""))
DataAppGPU50 <- read.csv(file = paste("./R-code/Datasets/AppGPU50.csv", sep = ""))
DataAppGPU52 <- read.csv(file = paste("./R-code/Datasets/AppGPU52.csv", sep = ""))


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

write.csv(DataAppGPU30, file = "./R-code/Datasets/CleanData/App-GPU-CC-30.csv")
write.csv(DataAppGPU35, file = "./R-code/Datasets/CleanData/App-GPU-CC-35.csv")
write.csv(DataAppGPU50, file = "./R-code/Datasets/CleanData/App-GPU-CC-50.csv")
write.csv(DataAppGPU52, file = "./R-code/Datasets/CleanData/App-GPU-CC-52.csv")

dim(DataAppGPU52)

write.csv(rbind(DataAppGPU30,DataAppGPU35,DataAppGPU50,DataAppGPU52), file = "./R-code/Datasets/CleanData/App-GPU-CC-All.csv")

