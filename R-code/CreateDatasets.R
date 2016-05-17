

dirpath <- "~/Doctorate/svm-gpuperf/"
setwd(paste(dirpath, sep=""))

gpus <- read.table("./ML-model/deviceInfo_L1disabled.csv", sep=",", header=T)
NoGPU <- dim(gpus)[1]

apps <- c("matMul_gpu_uncoalesced","matMul_gpu", "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem",
          "matrix_sum_normal", "matrix_sum_coalesced", 
          "dotProd", "vectorAdd",  "subSeqMax")

namesMetrics3X <- read.csv("./data/metricsNames-3X.csv",header = T, sep = ",")
namesEvents3X <- read.csv("./data/eventsNames-3X.csv", header = T, sep = ",")
namesTraces3X <- read.csv("./data/tracesNames-3X.csv",header = T, sep = ",")

namesMetrics5X <- read.csv("./data/metricsNames-5X.csv",header = T, sep = ",")
namesEvents5X <- read.csv("./data/eventsNames-5X.csv", header = T, sep = ",")
namesTraces5X <- read.csv("./data/tracesNames-5X.csv",header = T, sep = ",")
    
noSamples <- 10

AppGPUInfoAll3X <- data.frame()
AppGPUInfoAll5X <- data.frame()
for (i in 1:10){
    
    for (k in 1:length(apps)){
        GPUAppTemp <- data.frame()
        metricsTemp<- NULL
        eventsTemp <- NULL
        tracesTemp <- NULL
        for (j in c(8, 16, 32)){
            
            
            if (gpus[i,'compute_version'] == 3){
                if( apps[k] != "subSeqMax"){
                
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics3X), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents3X), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces3X), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(metricsTemp, eventsTemp[,-1], tracesTemp[,-1] , GpuName=gpus[i,'gpu_name'],  App=apps[k])
                } else if (j == 16) {
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics3X), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents3X), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces3X), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(metricsTemp, eventsTemp[,-1], tracesTemp[,-1] , GpuName=gpus[i,'gpu_name'],  App=apps[k])
                    }

                
                AppGPUInfoAll3X <- rbind(AppGPUInfoAll3X, GPUAppTemp)
            } else {
                if(apps[k] != "subSeqMax"){
                    
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics5X), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents5X), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces5X), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(metricsTemp, eventsTemp[,-1], tracesTemp[,-1] , GpuName=gpus[i,'gpu_name'],  App=apps[k])
                } else if (j == 16) {
                    metricsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-metrics.csv", sep=""), sep=",", header=F, col.names = names(namesMetrics5X), 
                                            stringsAsFactors = FALSE,strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    eventsTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-events.csv", sep=""), sep=",", header=F,  col.names = names(namesEvents5X), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    tracesTemp <- read.csv(paste("./data/", gpus[i,'gpu_name'],"/block_", j, "/", apps[k], "-kernel-traces.csv", sep=""), sep=",", header=F,  col.names = names(namesTraces5X), 
                                           stringsAsFactors = FALSE, strip.white = FALSE, na.strings = c("<OVERFLOW>"))
                    
                    print(paste(" Loaded ", gpus[i,'gpu_name'], "/", apps[k], ", BlockSize=",j, sep=""))
                    GPUAppTemp <- cbind(metricsTemp, eventsTemp[,-1], tracesTemp[,-1] , GpuName=gpus[i,'gpu_name'],  App=apps[k])
                }
                
                AppGPUInfoAll5X <- rbind(AppGPUInfoAll5X, GPUAppTemp)
                
                
            }

        }
    }
}
write.csv(AppGPUInfoAll3X, file = "Data-AppGPU3X.csv")
write.csv(AppGPUInfoAll5X, file = "Data-AppGPU5X.csv")

