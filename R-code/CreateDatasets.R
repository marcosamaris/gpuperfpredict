

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

noSamples <- 10

AppGPUInfoAll30 <- data.frame()
AppGPUInfoAll35 <- data.frame()
AppGPUInfoAll50 <- data.frame()
AppGPUInfoAll52 <- data.frame()
for (i in 1){
    
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
                    GPUAppTemp <- cbind(metricsTemp, eventsTemp[,-1], tracesTemp[,-1] , GpuName=gpus[i,'gpu_name'],  App=apps[k])
                } else if (j == 16) {
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics30), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents30), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(metricsTemp, eventsTemp[,-1], tracesTemp[,-1] , GpuName=gpus[i,'gpu_name'],  App=apps[k])
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
                    GPUAppTemp <- cbind(metricsTemp, eventsTemp[,-1], tracesTemp[,-1] , GpuName=gpus[i,'gpu_name'],  App=apps[k])
                } else if (j == 16) {
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics35), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents35), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(metricsTemp, eventsTemp[,-1], tracesTemp[,-1] , GpuName=gpus[i,'gpu_name'],  App=apps[k])
                }
                
                AppGPUInfoAll35 <- rbind(AppGPUInfoAll35, GPUAppTemp)
                
                
            } if (gpus[i,'compute_version'] == 5.0){
                if( apps[k] != "subSeqMax"){
                    
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics50), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents50), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(metricsTemp, eventsTemp[,-1], tracesTemp[,-1] , GpuName=gpus[i,'gpu_name'],  App=apps[k])
                } else if (j == 16) {
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics50), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents50), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(metricsTemp, eventsTemp[,-1], tracesTemp[,-1] , GpuName=gpus[i,'gpu_name'],  App=apps[k])
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
                    GPUAppTemp <- cbind(metricsTemp, eventsTemp[,-1], tracesTemp[,-1] , GpuName=gpus[i,'gpu_name'],  App=apps[k])
                } else if (j == 16) {
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics52), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents52), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(metricsTemp, eventsTemp[,-1], tracesTemp[,-1] , GpuName=gpus[i,'gpu_name'],  App=apps[k])
                }
                
                AppGPUInfoAll52 <- rbind(AppGPUInfoAll52, GPUAppTemp)
            }

        }
    }
}

drops <- c("Device","Device.1", "Stream", "Stream.1", "Kernel", "Kernel.1")
DF[ , !(names(DF) %in% drops)]

write.csv(AppGPUInfoAll3X, file = "AppGPU3X.csv")
write.csv(AppGPUInfoAll3X[AppGPUInfoAll3X["IdApp"]], file = "AppGPU3X.csv")



write.csv(AppGPUInfoAll5X, file = "AppGPU5X.csv")

