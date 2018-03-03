library("data.table")
library("ff")
library("ggplot2")

dirpath <- "~/Dropbox/Doctorate/GIT/BSyncGPGPU/"
setwd(paste(dirpath, sep = ""))

source("./code/include/common.R")
source("./code/include/sharedFunctions.R")

set.seed(5)

namesTraces <- read.csv("./data/tracesNames.csv",header = T, sep = ",")

tempFeatures <- data.frame()
for (kernelApp in c(1:13)) {
    tempApps <- data.frame()
    for (gpu in c(1:3, 5:10)) {
        tempAppGpu <- read.csv(paste("./datasets/", names(kernelsDict[kernelApp]), "-", gpus[gpu,'gpu_name'], ".csv", sep=""))
        tempAppGpu[1] <- tempAppGpu$input.size.1
        tempAppGpu[2] <- tempAppGpu$input.size.2
        tempAppGpu[3] <- tempAppGpu$duration
        tempAppGpu[4] <- tempAppGpu$grid.X*tempAppGpu$grid.y*tempAppGpu$block.x*tempAppGpu$block.y
        tempAppGpu[5] <- names(kernelsDict[kernelApp])
        tempAppGpu[6] <- gpu
        
        tempAppGpu[7] <- tempAppGpu$gld_inst_32bit
        tempAppGpu[8] <- tempAppGpu$gst_inst_32bit
        
        tempAppGpu[9] <- tempAppGpu$shared_load
        tempAppGpu[10] <- tempAppGpu$shared_store
        
        tempAppGpu[11] <- tempAppGpu$floating_point_operations.double_precision.	
        tempAppGpu[12] <- tempAppGpu$floating_point_operations.double_precision_add.	
        tempAppGpu[13] <- tempAppGpu$floating_point_operations.double_precision_mul.	
        tempAppGpu[14] <- tempAppGpu$floating_point_operations.double_precision_fma.
        
        tempAppGpu[15] <- tempAppGpu$floating_point_operations.single_precision.	
        tempAppGpu[16] <- tempAppGpu$floating_point_operations.single_precision_add.
        tempAppGpu[17] <- tempAppGpu$floating_point_operations.single_precision_mul
        tempAppGpu[18] <- tempAppGpu$floating_point_operations.single_precision_fma.
        
        tempAppGpu <- tempAppGpu[1:18]
        names(tempAppGpu) <- c("input.size.1", "input.size.2", "duration", "threads", "kernels", "gpu",
                               "gld_inst_32bit",
                               "gst_inst_32bit",
                               "shared_load",
                               "shared_store",
                               "floating_point_operations.double_precision.",
                               "floating_point_operations.double_precision_add.",	
                               "floating_point_operations.double_precision_mul.",	
                               "floating_point_operations.double_precision_fma.",
                               "floating_point_operations.single_precision.",
                               "floating_point_operations.single_precision_add.",
                               "floating_point_operation.single_precision_mul.",
                               "floating_point_operations.single_precision_fma.")
        tempApps <- rbind(tempApps, tempAppGpu)
    }
    tempFeatures <- rbind(tempApps, tempFeatures)
    rm(tempAppGpu)
}



FlopsTh <- gpus['max_clock_rate']*gpus['num_of_cores']

gSM <- 5; #Cycles per processor
gGM <- gSM* 100; #Cycles per processor

gL1 <- gSM; #Cycles per processor
gL2 <- gGM*0.5; #Cycles per processor

L1 <- 0
L2 <- 0

lambda <- matrix(nrow = NoGPU, ncol = 13, 0, dimnames = gpus['gpu_name'])
lambda[,1] <- c(5.5, 6, 6, 0, 6, 5, 3.5, 4, 4, 2.5)
lambda[,2] <- c(1.1, 0.85, 1.1, 0, 1, .85, 1.1, .75, 1, .65)
lambda[,3] <- c(0.2, 0.25, 0.2, 0, 0.2, 0.2, 0.6, 0.2, 0.3, 0.2)
lambda[,4] <- 1
lambda[,5] <- c(0.125, 0.125, 0.125, 0, 0.125, 0.1, 0.3, 0.15, 0.2, 0.175)
lambda[,6] <- c(10, 15, 15, 0, 15, 10, 10, 8, 9, 5)
lambda[,7] <- c(5, 5, 5, 0, 5, 4, 3, 2.5, 3, 2.5)
lambda[,8] <- c(0.025, 0.15, 0.15, 0, 0.15, 0.025, 0.0225, 0.02, 0.02, 0.015)
lambda[,9] <- c(0.003, 0.002, 0.002, 0, 0.0015, 0.0025, 0.0125, 0.002, 0.0035, 0.0025)
lambda[,10] <- 1
lambda[,11] <- 1
lambda[,12] <- 1
lambda[,13] <- 1

tempFeatures[apply(tempFeatures, 2, is.na)] <- as.integer(0)

appAllKernel <- data.frame()
for (gpu in c(2:3, 5:10)) {
    
    ##### Back Propagation bpnn_layerforward_CUDA - Kernel 1
    
    N <- seq(8192, 65536, 1024)
    
    tileWidth <- 16
    threadsPerBlock <- tileWidth*tileWidth
    blocksPerGrid <- as.integer((N +  tileWidth -1)/tileWidth)
    
    numberthreads <- tempFeatures$threads[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[1])]
    
    numberMultiplication <- 1
    pow2 <- 4
    numberSum <- 4
    
    Comp <-  tempFeatures$floating_point_operations.single_precision.[tempFeatures$gpu == gpu & 
                                         tempFeatures$kernels == names(kernelsDict[1])]*50 
    
    gmRead <- tempFeatures$gld_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[1])] 
    gmStore <- tempFeatures$gst_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[1])] 
    
    smRead <- tempFeatures$shared_load[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[1])] 
    smStore <-tempFeatures$shared_store[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[1])] 
    
    CommGM <- (gmStore + gmRead - L1 - L2)*gGM + L1*gL1 + L2*gL2;
    CommSM <- (smStore + smRead)*gSM;
    
    timeKernel <-  1*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 1]);
    
    # predicted<-timeKernel
    measured<-tempFeatures$duration[tempFeatures$gpu == gpu &
                                        tempFeatures$kernels == names(kernelsDict[1])] # &
    #                           # tempFeatures$input.size.1 == N[i]]
    
    #  plot(measured, ylim=range(min(measured, predicted), max(measured, predicted)))
    #  points(predicted,col="red")
    # }
    
    appAllKernel <- rbind(appAllKernel,
                          data.frame(measured=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                            tempFeatures$kernels == names(kernelsDict[1])],
                                     predicted=timeKernel,
                                     accuracy=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                            tempFeatures$kernels == names(kernelsDict[1])]/timeKernel,
                                     kernels=names(kernelsDict[1]),
                                     gpu=gpus[gpu,"gpu_name"],
                                     modeling="modeling"))

    #
    #
    ##### Back Propagation bpnn_adjust_weights_cuda - Kernel 2
    
    numberthreads <- tempFeatures$threads[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[2])];
    
    Comp <- as.numeric(tempFeatures$floating_point_operations.double_precision_fma.[tempFeatures$kernels == names(kernelsDict[2])])*10 
    
    gmRead <- tempFeatures$gld_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[2])] 
    gmStore <- tempFeatures$gst_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[2])] 
    
    smRead <- tempFeatures$shared_load[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[2])] 
    smStore <-tempFeatures$shared_store[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[2])] 
    
    CommGM <- (gmStore + gmRead - L1 - L2)*gGM + L1*gL1 + L2*gL2;
    CommSM <- (smStore + smRead)*gSM;
    
    timeKernel <- 1*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)* lambda[gpu,2]);
    
    # predicted<-timeKernel
    # measured<-tempFeatures$duration[tempFeatures$gpu == gpu &
    #                           tempFeatures$kernels == names(kernelsDict[3])] # &
    #                           # tempFeatures$input.size.1 == N[i]]
    
    #  plot(measured, ylim=range(min(measured, predicted), max(measured, predicted)), main=N[i])
    #  points(predicted,col="red")
    # }
    
    
    appAllKernel <- rbind(appAllKernel,
                          data.frame(measured=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[2])],
                                     predicted=timeKernel,
                                     accuracy=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[2])]/timeKernel,
                                     kernels=names(kernelsDict[2]),
                                     gpu=gpus[gpu,"gpu_name"],
                                     modeling="modeling"))
    
    #
    #     ########################### Gaussian Fan1  - Kernel 3
    
    N <- seq(2048, 8192, 256)
    # N = 256
    
    numberthreads <- NULL
    for (i in 1:length(N)){
        numberthreads <- c(numberthreads,rep(N[i], N[i]-1))
    }
    
    numberthreads <- tempFeatures$threads[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[3]) &
                                              tempFeatures$input.size.1 >= 2048];
    
    Comp <-  tempFeatures$floating_point_operations.single_precision.[tempFeatures$gpu == gpu & 
                                                 tempFeatures$kernels == names(kernelsDict[3])]*50 
    
    gmRead <- tempFeatures$gld_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[3])] 
    gmStore <- tempFeatures$gst_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[3])] 
    
    smRead <- tempFeatures$shared_load[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[3])] 
    smStore <-tempFeatures$shared_store[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[3])] 
    
    CommGM <- (gmStore + gmRead - L1 - L2)*gGM + L1*gL1 + L2*gL2;
    CommSM <- (smStore + smRead)*gSM;
    
    timeKernel <- 1*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 3]);
    
    # predicted<-timeKernel
    # measured<-tempFeatures$duration[tempFeatures$gpu == gpu &
    #                           tempFeatures$kernels == names(kernelsDict[3])] # &
    #                           # tempFeatures$input.size.1 == N[i]]
    
    #  plot(measured, ylim=range(min(measured, predicted), max(measured, predicted)), main=N[i])
    #  points(predicted,col="red")
    # }
    
    
    appAllKernel <- rbind(appAllKernel,
                          data.frame(measured=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[3])],
                                     predicted=timeKernel,
                                     accuracy=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[3])]/timeKernel,
                                     kernels=names(kernelsDict[3]),
                                     gpu=gpus[gpu,"gpu_name"],
                                     modeling="modeling"))
    
    
    ########################### Gaussian Fan2 - Kernel 4
    
    N <- seq(2048, 8192, 256)
    tileSize = 4
    threadsPerBlock <- tileSize*tileSize
    blocksPerGrid <- ceiling((N/tileSize))^2
    #gridsizes <- ceiling((N/threadsPerBlock) + (!(N %% threadsPerBlock)));
    # numberthreads <- threadsPerBlock * blocksPerGrid
    
    numberthreads <- NULL
    for (i in 1:length(N)){
        numberthreads <- c(numberthreads,rep(N[i], N[i]-1))
    }
    
    numberthreads <- tempFeatures$threads[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[4]) &
                                              tempFeatures$input.size.1 >= 2048];
    
    # numberthreads <- NULL
    # for (i in 1:length(N)){
    #     numberthreads <- c(rep(N[i], N[i]-1))
    Comp <-  tempFeatures$floating_point_operations.single_precision.[tempFeatures$gpu == gpu & 
                                                                          tempFeatures$kernels == names(kernelsDict[4])]*50 
    
    gmRead <- tempFeatures$gld_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[4])] 
    gmStore <- tempFeatures$gst_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[4])] 
    
    smRead <- tempFeatures$shared_load[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[4])] 
    smStore <-tempFeatures$shared_store[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[4])] 
    
    CommGM <- (gmStore + gmRead - L1 - L2)*gGM + L1*gL1 + L2*gL2;
    CommSM <- (smStore + smRead)*gSM;
    
    timeKernel <- 1*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 4]);
    predicted<-timeKernel
    # measured<-tempFeatures$duration[tempFeatures$gpu == gpu &
    #                           tempFeatures$kernels == names(kernelsDict[4]) &
    #                           tempFeatures$input.size.1 >= 2048]
    
    # par(mfrow=c(1,2))
    #  plot(measured, ylim=range(min(measured, predicted), max(measured, predicted)), main=N[i])
    #  points(predicted,col="red")
    #  boxplot(measured/predicted, main=N[i])
    
    
    appAllKernel <- rbind(appAllKernel,
                          data.frame(measured=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[4])],
                                     predicted=timeKernel,
                                     accuracy=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[4])]/timeKernel,
                                     kernels=names(kernelsDict[4]),
                                     gpu=gpus[gpu,"gpu_name"],
                                     modeling="modeling"))
    
    # 
    #        
    #         ########################### Hearthwall kernel 5
    
    
    N <- seq(20, 104)
    N <- rep(N, N)
    
    threadsPerBlock <- 256
    blocksPerGrid <- 51
    
    numberthreads <- (N/N)*13056
    numberthreads <- tempFeatures$threads[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[5])];
    
    Comp <-  tempFeatures$floating_point_operations.single_precision.[tempFeatures$gpu == gpu & 
                                                                          tempFeatures$kernels == names(kernelsDict[5])]*50 
    
    gmRead <- tempFeatures$gld_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[5])] 
    gmStore <- tempFeatures$gst_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[5])] 
    
    smRead <- tempFeatures$shared_load[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[5])] 
    smStore <-tempFeatures$shared_store[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[5])] 
    
    CommGM <- (gmStore + gmRead - L1 - L2)*gGM + L1*gL1 + L2*gL2;
    CommSM <- (smStore + smRead)*gSM;
    
    timeKernel <- 1*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 5]);
    
    predicted <- timeKernel
    # measured <- tempFeatures$duration[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[5]) ]
    # par(mfrow=c(1,2))
    # plot(measured, ylim=range(min(measured, predicted), max(measured, predicted)), main=N[i])
    # points(predicted,col="red")
    # boxplot(measured/predicted, main=N[i])
    
    appAllKernel <- rbind(appAllKernel,
                          data.frame(measured=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[5])],
                                     predicted=timeKernel,
                                     accuracy=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[5])]/timeKernel,
                                     kernels=names(kernelsDict[5]),
                                     gpu=gpus[gpu,"gpu_name"],
                                     modeling="modeling"))
    
    
    #     
    #     ########################### Hotspot calculate_temp
    
    N_i <- c(64, 128, 256, 512, 1024)
    N_j <- seq(32, 4096, 32)
    threadsPerBlock <- 16 * 16
    blocksPerGrid <- (as.integer((N_i/(16-4))+1)^2)
    
    numberthreads <- c(rep(blocksPerGrid[1]*threadsPerBlock, 1280),
                       rep(blocksPerGrid[2]*threadsPerBlock, 1280),
                       rep(blocksPerGrid[3]*threadsPerBlock, 1280),
                       rep(blocksPerGrid[4]*threadsPerBlock, 1280),
                       rep(blocksPerGrid[5]*threadsPerBlock, 1280));
    
    numberthreads <- tempFeatures$threads[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[6])];
    
    Comp <-  tempFeatures$floating_point_operations.single_precision.[tempFeatures$gpu == gpu & 
                                                                          tempFeatures$kernels == names(kernelsDict[6])]*50 
    
    gmRead <- tempFeatures$gld_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[6])] 
    gmStore <- tempFeatures$gst_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[6])] 
    
    smRead <- tempFeatures$shared_load[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[6])] 
    smStore <-tempFeatures$shared_store[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[6])] 
    
    CommGM <- (gmStore + gmRead - L1 - L2)*gGM + L1*gL1 + L2*gL2;
    CommSM <- (smStore + smRead)*gSM;
    
    timeKernel <- 1*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 6]);
    
    predicted <- timeKernel
    measured <- tempFeatures$duration[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[6])]
    # summary(measured/predicted)
    # length(numberthreads)
    # length(measured)
    
    
    # par(mfrow=c(1,2))
    # plot(measured, ylim=range(min(measured, predicted), max(measured, predicted)))
    # points(predicted,col="red")
    # boxplot(measured/predicted)
    
    appAllKernel <- rbind(appAllKernel,
                          data.frame(measured=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[6])],
                                     predicted=timeKernel,
                                     accuracy=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[6])]/timeKernel,
                                     kernels=names(kernelsDict[6]),
                                     gpu=gpus[gpu,"gpu_name"],
                                     modeling="modeling"))
    
    #     ########################### Hotspot_3D hotspotOpt1
    # 
    
    
    N_i <- c(2, 4, 8)
    N_j <- seq(100, 1000, 100)
    
    N = rep(N_j, N_j/2)
    N = rep(N, 3)
    
    threadsPerBlock <- 64 * 4
    blocksPerGrid <- 8 * 128
    
    numberthreads <- threadsPerBlock * blocksPerGrid
    numberthreads <- tempFeatures$threads[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[7])];
    
    Comp <-  tempFeatures$floating_point_operations.single_precision.[tempFeatures$gpu == gpu & 
                                                                          tempFeatures$kernels == names(kernelsDict[7])]*50 
    
    gmRead <- tempFeatures$gld_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[7])] 
    gmStore <- tempFeatures$gst_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[7])] 
    
    smRead <- tempFeatures$shared_load[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[7])] 
    smStore <-tempFeatures$shared_store[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[7])] 
    
    CommGM <- (gmStore + gmRead - L1 - L2)*gGM + L1*gL1 + L2*gL2;
    CommSM <- (smStore + smRead)*gSM;
    
    timeKernel <- 1*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 7]);
    
    predicted <- timeKernel
    measured <- tempFeatures$duration[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[7])]
    # summary(measured/predicted)
    # length(numberthreads)
    # length(measured)
    
    # par(mfrow=c(1,2))
    # plot(measured, ylim=range(min(measured, predicted), max(measured, predicted)))
    # points(predicted,col="red")
    # boxplot(measured/predicted)
    
    appAllKernel <- rbind(appAllKernel,
                          data.frame(measured=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[7])],
                                     predicted=timeKernel,
                                     accuracy=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[7])]/timeKernel,
                                     kernels=names(kernelsDict[7]),
                                     gpu=gpus[gpu,"gpu_name"],
                                     modeling="modeling"))
    
    #     
    #     ########################### lavaMD kernel_gpu_cuda
    #     
    
    
    N <- 5:100
    
    threadsPerBlock <- 64 * 4
    blocksPerGrid <- 128
    
    numberthreads <- tempFeatures$threads[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[8])];
    
    Comp <-  tempFeatures$floating_point_operations.single_precision.[tempFeatures$gpu == gpu & 
                                                                          tempFeatures$kernels == names(kernelsDict[8])]*50 
    
    gmRead <- tempFeatures$gld_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[8])] 
    gmStore <- tempFeatures$gst_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[8])] 
    
    smRead <- tempFeatures$shared_load[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[8])] 
    smStore <-tempFeatures$shared_store[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[8])] 
    
    CommGM <- (gmStore + gmRead - L1 - L2)*gGM + L1*gL1 + L2*gL2;
    CommSM <- (smStore + smRead)*gSM;
    
    timeKernel <- 1*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 8]);
    
    predicted <- timeKernel
    measured <- tempFeatures$duration[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[8])]
    # summary(measured/predicted)
    # length(numberthreads)
    # length(measured)
    
    # par(mfrow=c(1,2))
    # plot(measured, ylim=range(min(measured, predicted), max(measured, predicted)))
    # points(predicted,col="red")
    # boxplot(measured/predicted)
    
    appAllKernel <- rbind(appAllKernel,
                          data.frame(measured=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[8])],
                                     predicted=timeKernel,
                                     accuracy=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[8])]/timeKernel,
                                     kernels=names(kernelsDict[8]),
                                     gpu=gpus[gpu,"gpu_name"],
                                     modeling="modeling"))
    
    
    #     ########################### LU decomposition - lud_diagonal
    
    N <- seq(256, 8192, 256)
    N_diagonal <- rep(N, N/16)
    
    threadsPerBlock <- 16
    blocksPerGrid <- 1
    
    numberthreads <- threadsPerBlock * blocksPerGrid
    numberthreads <- tempFeatures$threads[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[9])];
    
    Comp <-  tempFeatures$floating_point_operations.single_precision.[tempFeatures$gpu == gpu & 
                                                                          tempFeatures$kernels == names(kernelsDict[9])]*50 
    
    gmRead <- tempFeatures$gld_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[9])] 
    gmStore <- tempFeatures$gst_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[9])] 
    
    smRead <- tempFeatures$shared_load[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[9])] 
    smStore <-tempFeatures$shared_store[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[9])] 
    
    CommGM <- (gmStore + gmRead - L1 - L2)*gGM + L1*gL1 + L2*gL2;
    CommSM <- (smStore + smRead)*gSM;
    
    timeKernel <- 1*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 9]);
    
    predicted <- timeKernel
    measured <- tempFeatures$duration[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[9])]
    # summary(measured/predicted)
    # length(numberthreads)
    # length(measured)
    
    # par(mfrow=c(1,2))
    # plot(measured, ylim=range(min(measured, predicted), max(measured, predicted)))
    # points(predicted,col="red")
    # boxplot(measured/predicted)
    
    appAllKernel <- rbind(appAllKernel,
                          data.frame(measured=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[9])],
                                     predicted=timeKernel,
                                     accuracy=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[9])]/timeKernel,
                                     kernels=names(kernelsDict[9]),
                                     gpu=gpus[gpu,"gpu_name"],
                                     modeling="modeling"))
    
    #     ######################## LUD lud_perimeter
    
    
    N_perimeter <- rep(N, N/16 -1)
    
    threadsPerBlock <- 16
    blocksPerGrid <- 1
    
    numberthreads <- threadsPerBlock * blocksPerGrid
    numberthreads <- tempFeatures$threads[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[10])];
    
    Comp <-  tempFeatures$floating_point_operations.single_precision.[tempFeatures$gpu == gpu & 
                                                                          tempFeatures$kernels == names(kernelsDict[10])]*50 
    
    gmRead <- tempFeatures$gld_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[10])] 
    gmStore <- tempFeatures$gst_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[10])] 
    
    smRead <- tempFeatures$shared_load[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[10])] 
    smStore <-tempFeatures$shared_store[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[10])] 
    
    CommGM <- (gmStore + gmRead - L1 - L2)*gGM + L1*gL1 + L2*gL2;
    CommSM <- (smStore + smRead)*gSM;
    
    timeKernel <- 1*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 10]);
    
    predicted <- timeKernel
    measured <- tempFeatures$duration[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[10])]
    # summary(measured/predicted)
    # length(numberthreads)
    # length(measured)
    
    
    # par(mfrow=c(1,2))
    # plot(measured, ylim=range(min(measured, predicted), max(measured, predicted)))
    # points(predicted,col="red")
    # boxplot(measured/predicted)
    
    appAllKernel <- rbind(appAllKernel,
                          data.frame(measured=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[10])],
                                     predicted=timeKernel,
                                     accuracy=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[10])]/timeKernel,
                                     kernels=names(kernelsDict[10]),
                                     gpu=gpus[gpu,"gpu_name"],
                                     modeling="modeling"))
    #     
    #     ############################ LUD lud_internal
    N_perimeter <- rep(N, N/16 -1)
    
    threadsPerBlock <- 16
    blocksPerGrid <- 1
    
    numberthreads <- threadsPerBlock * blocksPerGrid
    numberthreads <- tempFeatures$threads[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[11])];
    
    Comp <-  tempFeatures$floating_point_operations.single_precision.[tempFeatures$gpu == gpu & 
                                                                          tempFeatures$kernels == names(kernelsDict[11])]*50 
    
    gmRead <- tempFeatures$gld_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[11])] 
    gmStore <- tempFeatures$gst_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[11])] 
    
    smRead <- tempFeatures$shared_load[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[11])] 
    smStore <-tempFeatures$shared_store[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[11])] 
    
    CommGM <- (gmStore + gmRead - L1 - L2)*gGM + L1*gL1 + L2*gL2;
    CommSM <- (smStore + smRead)*gSM;
    
    timeKernel <- 1*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 11]);
    
    predicted <- timeKernel
    measured <- tempFeatures$duration[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[11])]
    # summary(measured/predicted)
    # length(numberthreads)
    # length(measured)
    
    
    # par(mfrow=c(1,2))
    # plot(measured, ylim=range(min(measured, predicted), max(measured, predicted)))
    # points(predicted,col="red")
    # boxplot(measured/predicted)
    
    appAllKernel <- rbind(appAllKernel,
                          data.frame(measured=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[11])],
                                     predicted=timeKernel,
                                     accuracy=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[11])]/timeKernel,
                                     kernels=names(kernelsDict[11]),
                                     gpu=gpus[gpu,"gpu_name"],
                                     modeling="modeling"))
    #     
    #     
    #     ######################### Needleman-Wunsch needle_cuda_shared_1
    
    N_i <- seq(256, 4096, 256)
    N_j <- 1:10
    
    threadsPerBlock <- 16
    blocksPerGrid <- NULL
    for (i in 1:length(N_i)){
        blocksPerGrid <- c(blocksPerGrid, seq(1,N_i[i]/16))
    }
    
    numberthreads <- tempFeatures$threads[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[12])]
    
    Comp <-  tempFeatures$floating_point_operations.single_precision.[tempFeatures$gpu == gpu & 
                                                                          tempFeatures$kernels == names(kernelsDict[12])]*50 
    
    gmRead <- tempFeatures$gld_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[12])] 
    gmStore <- tempFeatures$gst_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[12])] 
    
    smRead <- tempFeatures$shared_load[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[12])] 
    smStore <-tempFeatures$shared_store[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[12])] 
    
    CommGM <- (gmStore + gmRead - L1 - L2)*gGM + L1*gL1 + L2*gL2;
    CommSM <- (smStore + smRead)*gSM;
    
    timeKernel <- 1*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 12]);
    
    predicted <- timeKernel
    measured <- tempFeatures$duration[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[12])]
    # summary(measured/predicted)
    # length(numberthreads)
    # length(measured)
    
    
    # par(mfrow=c(1,2))
    # plot(measured, ylim=range(min(measured, predicted), max(measured, predicted)))
    # points(predicted,col="red")
    # boxplot(measured/predicted)
    
    appAllKernel <- rbind(appAllKernel,
                          data.frame(measured=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[12])],
                                     predicted=timeKernel,
                                     accuracy=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[12])]/timeKernel,
                                     kernels=names(kernelsDict[12]),
                                     gpu=gpus[gpu,"gpu_name"],
                                     modeling="modeling"))
    
    #     ######################### Needleman-Wunsch needle_cuda_shared_2
    
    N_i <- seq(256, 4096, 256)
    N_j <- 1:10
    
    threadsPerBlock <- 16
    blocksPerGrid <- NULL
    for (i in 1:length(N_i)){
        blocksPerGrid <- c(blocksPerGrid, seq(N_i[i]/16-1 , 1))
    }
    
    numberthreads <- tempFeatures$threads[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[13])]
    
    Comp <-  tempFeatures$floating_point_operations.single_precision.[tempFeatures$gpu == gpu & 
                                                                          tempFeatures$kernels == names(kernelsDict[13])]*50 
    
    gmRead <- tempFeatures$gld_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[13])] 
    gmStore <- tempFeatures$gst_inst_32bit[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[13])] 
    
    smRead <- tempFeatures$shared_load[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[13])] 
    smStore <-tempFeatures$shared_store[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[13])] 
    
    CommGM <- (gmStore + gmRead - L1 - L2)*gGM + L1*gL1 + L2*gL2;
    CommSM <- (smStore + smRead)*gSM;
    
    timeKernel <- 1*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 13]);
    
    predicted <- timeKernel
    measured <- tempFeatures$duration[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[13])]
    # summary(measured/predicted)
    # length(numberthreads)
    # length(measured)
    
    # par(mfrow=c(1,2))
    # plot(measured, ylim=range(min(measured, predicted), max(measured, predicted)))
    # points(predicted,col="red")
    # boxplot(measured/predicted)
    
    appAllKernel <- rbind(appAllKernel,
                          data.frame(measured=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[13])],
                                     predicted=timeKernel,
                                     accuracy=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[13])]/timeKernel,
                                     kernels=names(kernelsDict[13]),
                                     gpu=gpus[gpu,"gpu_name"],
                                     modeling="modeling"))
}



Graph <- ggplot(appAllKernel, aes(x = gpu, y = accuracy, group = gpu, col = gpu)) +
    geom_boxplot(size=1, outlier.size = 2.5) +
    stat_boxplot(geom ='errorbar') +
    xlab(" ") + 
    theme_bw() +        
    ylab(expression(paste("Accuracy ",T[k]/T[m] ))) +
    facet_wrap(kernels~modeling, scales = "free")

ggsave(paste("./images/analyticalModel/Analyticalmodel-traces.png", sep = ""), Graph, height = 10, width = 20)

write.csv(appAllKernel, file = paste("./results/Rodinia-BSP-Modeling-traces.csv", sep=""))






