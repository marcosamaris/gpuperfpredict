

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
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(GpuName=gpus[i,'gpu_name'],  GpuId=gpus[i,'gpu_id'], AppName=apps[k], AppId=k, metricsTemp, eventsTemp[,-1], tracesTemp[,-1][1:11])
                } else if (j == 16) {
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics30), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents30), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(GpuName=gpus[i,'gpu_name'],  GpuId=gpus[i,'gpu_id'], AppName=apps[k], AppId=k, metricsTemp, eventsTemp[,-1], tracesTemp[,-1][1:11])
                }
                
                AppGPUInfoAll30 <- rbind(AppGPUInfoAll30, GPUAppTemp)
            } else if (gpus[i,'compute_version'] == 3.5) {
                if(apps[k] != "subSeqMax"){
                    
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics35), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents35), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(GpuName=gpus[i,'gpu_name'],  GpuId=gpus[i,'gpu_id'], AppName=apps[k], AppId=k, metricsTemp, eventsTemp[,-1], tracesTemp[,-1][1:11])
                } else if (j == 16) {
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics35), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents35), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(GpuName=gpus[i,'gpu_name'],  GpuId=gpus[i,'gpu_id'], AppName=apps[k], AppId=k, metricsTemp, eventsTemp[,-1], tracesTemp[,-1][1:11])
                }
                
                AppGPUInfoAll35 <- rbind(AppGPUInfoAll35, GPUAppTemp)
                
                
            } else if (gpus[i,'compute_version'] == 5.0){
                if( apps[k] != "subSeqMax"){
                    
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics50), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents50), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(GpuName=gpus[i,'gpu_name'],  GpuId=gpus[i,'gpu_id'], AppName=apps[k], AppId=k, metricsTemp, eventsTemp[,-1], tracesTemp[,-1][1:11])
                } else if (j == 16) {
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics50), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents50), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(GpuName=gpus[i,'gpu_name'],  GpuId=gpus[i,'gpu_id'], AppName=apps[k], AppId=k, metricsTemp, eventsTemp[,-1], tracesTemp[,-1][1:11])
                }
                
                AppGPUInfoAll50 <- rbind(AppGPUInfoAll50, GPUAppTemp)
            } else if (gpus[i,'compute_version'] == 5.2) {
                if(apps[k] != "subSeqMax"){
                    
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics52), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents52), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(GpuName=gpus[i,'gpu_name'],  GpuId=gpus[i,'gpu_id'], AppName=apps[k], AppId=k, metricsTemp, eventsTemp[,-1], tracesTemp[,-1][1:11])
                } else if (j == 16) {
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics52), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents52), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(GpuName=gpus[i,'gpu_name'],  GpuId=gpus[i,'gpu_id'], AppName=apps[k], AppId=k, metricsTemp, eventsTemp[,-1], tracesTemp[,-1][1:11])
                }
                
                AppGPUInfoAll52 <- rbind(AppGPUInfoAll52, GPUAppTemp)
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
write.csv(AppGPUInfoAll30[AppGPUInfoAll30["GpuId"] == 1,], file = paste("./R-code/Datasets/Gpus/", gpus[1,'gpu_name'], ".csv", sep = ""))
write.csv(AppGPUInfoAll35[AppGPUInfoAll35["GpuId"] == 2,], file = paste("./R-code/Datasets/Gpus/", gpus[2,'gpu_name'], ".csv", sep = ""))
write.csv(AppGPUInfoAll35[AppGPUInfoAll35["GpuId"] == 3,], file = paste("./R-code/Datasets/Gpus/", gpus[3,'gpu_name'], ".csv", sep = ""))
write.csv(AppGPUInfoAll35[AppGPUInfoAll35["GpuId"] == 4,], file = paste("./R-code/Datasets/Gpus/", gpus[4,'gpu_name'], ".csv", sep = ""))
write.csv(AppGPUInfoAll35[AppGPUInfoAll35["GpuId"] == 5,], file = paste("./R-code/Datasets/Gpus/", gpus[5,'gpu_name'], ".csv", sep = ""))
write.csv(AppGPUInfoAll35[AppGPUInfoAll35["GpuId"] == 6,], file = paste("./R-code/Datasets/Gpus/", gpus[6,'gpu_name'], ".csv", sep = ""))
write.csv(AppGPUInfoAll50[AppGPUInfoAll50["GpuId"] == 7,], file = paste("./R-code/Datasets/Gpus/", gpus[7,'gpu_name'], ".csv", sep = ""))
write.csv(AppGPUInfoAll52[AppGPUInfoAll52["GpuId"] == 8,], file = paste("./R-code/Datasets/Gpus/", gpus[8,'gpu_name'], ".csv", sep = ""))
write.csv(AppGPUInfoAll52[AppGPUInfoAll52["GpuId"] == 9,], file = paste("./R-code/Datasets/Gpus/", gpus[9,'gpu_name'], ".csv", sep = ""))
write.csv(AppGPUInfoAll52[AppGPUInfoAll52["GpuId"] == 10,], file = paste("./R-code/Datasets/Gpus/", gpus[10,'gpu_name'], ".csv", sep = ""))



##### Create Datasets for each Application and each GPU
for (i in 1:NoGPU){
    if(gpus[i,'compute_version'] == 3.0){
        for (k in 1:length(apps)){
            write.csv(AppGPUInfoAll30[AppGPUInfoAll30$AppId == k & AppGPUInfoAll30$GpuId == i,], 
                      file = paste("./R-code/Datasets/Apps-Gpus/", apps[k], "-", gpus[i,'gpu_name'], ".csv", sep = ""))
        }
    }
    
    if(gpus[i,'compute_version'] == 3.5){
        for (k in 1:length(apps)){
            write.csv(AppGPUInfoAll35[AppGPUInfoAll30$AppId == k & AppGPUInfoAll35$GpuId == i,], 
                      file = paste("./R-code/Datasets/Apps-Gpus/", apps[k], "-", gpus[i,'gpu_name'], ".csv", sep = ""))
        }
    }
    
    if(gpus[i,'compute_version'] == 5.0){
        for (k in 1:length(apps)){
            write.csv(AppGPUInfoAll30[AppGPUInfoAll50$AppId == k & AppGPUInfoAll50$GpuId == i,], 
                      file = paste("./R-code/Datasets/Apps-Gpus/", apps[k], "-", gpus[i,'gpu_name'], ".csv", sep = ""))
        }
    }
    
    if(gpus[i,'compute_version'] == 5.2){
        for (k in 1:length(apps)){
            write.csv(AppGPUInfoAll52[AppGPUInfoAll52$AppId == k & AppGPUInfoAll52$GpuId == i,], 
                      file = paste("./R-code/Datasets/Apps-Gpus/", apps[k], "-", gpus[i,'gpu_name'], ".csv", sep = ""))
        }
    }
}






