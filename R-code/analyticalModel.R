library(ggplot2)
library(reshape2)

cbbPalette <- gray(1:9/ 12)#c("red", "blue", "darkgray", "orange","black","brown", "lightblue","violet")
dirpath <- "./Doctorate/svm-gpuperf/"
setwd(paste(dirpath, sep=""))

gpus <- read.table("./ML-model/deviceInfo.csv", sep=",", header=T)
NoGPU <- dim(gpus)[1]

apps <- c("matMul_gpu_uncoalesced","matMul_gpu", "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem",
         "matrix_sum_normal", "matrix_sum_coalesced", 
         "dotProd", "vectorAdd",  "subSeqMax")

flopsTheoreticalPeak <- gpus['max_clock_rate']*gpus['num_of_cores']
lambda <- matrix(nrow = NoGPU,ncol = length(apps), 0)

lambdaK40 <- c(4.30, 20, 19, 65 ,  2.50,  9.50,  9 , 10,  0.48)
lambdaK40L1 <- c(3.5,   20, 19,   65, 2.75,  9.5,    9,   10, 0.48)
lambdaGTX680 <- c(3.5,   18,   22,   65, 1.5,  8.25, 13.0, 11.0, 0.65)
lambdaTitan <- c(4.25,  21,   17,  50, 2.5, 10,  9.5,   12, 0.48)
lambdaK20 <- c(4.5,   21,   18,   52, 2.5,  9,  9.5,   10, 0.5)
lambdaQ <- c(4.5,   20,   20,   64, 1.75,  8.25, 11,  9.5, 0.55)
lambdaQL1 <- c(3.35, 20 , 25 , 64,  1.75,  8.5, 11 ,  9.50,  0.5)
lambdaTitanX <- c(10 ,   35,   35,  110, 3,  9.50,  8,  9.5, 0.95)
lambdaTitanBlack <- c(3.5,   17,   17,   52, 2,  7.5,  7.25,  8.5, 0.35)
lambdaTitanBlackL1 <- c(2.25,   17,   18,   52, 2,  7.5,  7.25,  8.5, 0.35)
lambdaGTX980 <- c(6,   26,   24,   76, 1.75,  5.5,  7.5,  5.5, 1.15)
lambdaGTX970 <- c(13,  40,  37, 120,   3,   9,  11,   8.5,   1.6)
lambdaGTX750 <- c(10,   42,   40,  138, 3.5, 14, 22, 15, 2.17)

lambda[1,] <- lambdaK40
lambda[2,] <- lambdaK40L1
lambda[3,] <- lambdaGTX680
lambda[4,] <- lambdaTitan
lambda[5,] <- lambdaK20
lambda[6,] <- lambdaQ
lambda[7,] <- lambdaQL1
lambda[8,] <- lambdaTitanX
lambda[9,] <- lambdaTitanBlack
lambda[10,] <- lambdaTitanBlackL1
lambda[11,] <- lambdaGTX980
lambda[12,] <- lambdaGTX970
lambda[13,] <- lambdaGTX750

library(xtable)
dflambda <- data.frame(lambda)
xtable(lambda[1:10,])

fm1 <- aov(tlimth ~ gpus[k,'gpu_name'], data = dflambda)


dataGPUsApps <- data.frame()

for (k in 1:9){

    TimeApp <- list()
    for (i in 1:length(apps)){
        if (gpus[k,'gpu_name'] == "Tesla-K40-UsingL1" | gpus[k,'gpu_name'] == "GTX-680" | gpus[k,'gpu_name'] == "Quadro"){
            print(paste(" Loaded ", gpus[k,'gpu_name'], "/", apps[i], "/Run_1 ", sep=""))
            data <- read.table(paste("./data/", gpus[k,'gpu_name'],"/run_1/", apps[i], "-kernel-traces.csv", sep=""), sep=",", header=F)
        } 
        else {
            data <- read.table(paste("./data/", gpus[k,'gpu_name'],"/run_0/", apps[i], "-kernel-traces.csv", sep=""), sep=",", header=F)
            print(paste(" Loaded ", gpus[k,'gpu_name'], "/", apps[i], "/Run_0 ", sep=""))
        }
      TimeApp[apps[i]] <- data['V3']
    }
    
    latencySharedMemory <- 5; #Cycles per processor
    latencyGlobalMemory <- latencySharedMemory* 100; #Cycles per processor
    
    latencyL1 <- latencySharedMemory; #Cycles per processor
    latencyL2 <- latencyGlobalMemory*0.5; #Cycles per processor
    
    SpeedupMatMul <- list()
    timeKernelMatMul <- list()
    for (i in 1:4){
        if (gpus[k,'gpu_name'] == "GTX-680"){
            N <- seq(from = 256, to = 4096, length.out = 16)
        }
        else {
            N <- seq(from = 256, to = 8192, length.out = 32)
        }
        numberMultiplication <- N;
        
        tileWidth <- 16;
        threadsPerBlock <- tileWidth*tileWidth;
        
        gridsizes <- as.integer((N +  tileWidth -1)/tileWidth);
        blocknumber <- gridsizes*gridsizes
        numberthreads <- threadsPerBlock * blocknumber;
        
        reads <- numberthreads*N*2
        timeComputationKernel <- ((numberMultiplication * 1) ) * numberthreads;
        
        L1Effect <- 0
        L2Effect <- 0
        
        CommGM <- ((numberthreads*N*2 - L1Effect - L2Effect + numberthreads)*latencyGlobalMemory + L1Effect*latencyL1 + L2Effect*latencyL2);
        if (apps[i] == "matMul_gpu_uncoalesced" | lambda[k,i] == 0 ){
            lambda[k,i] <- 10
        }
        if (apps[i] == "matMul_gpu" | lambda[k,i] == 0 ){
            lambda[k,i] <- 42
        }
        if (apps[i] == "matMul_gpu_sharedmem_uncoalesced" | lambda[k,i] == 0 ){
            lambda[k,i] <- 40
        }
        if (apps[i] == "matMul_gpu_sharedmem" | lambda[k,i] == 0 ){
            lambda[k,i] <- 138
        }

        timeKernel <- ( lambda[k,i]^-1*(timeComputationKernel + CommGM)/(flopsTheoreticalPeak[k,]*10^6));
        timeKernelMatMul[[apps[i]]] <- timeKernel
        SpeedupMatMul[[apps[i]]] <- timeKernel[1:length(TimeApp[[apps[i]]])]/TimeApp[[apps[i]]];
    }
    SpeedupMatMul
    
    SpeedupMatSum <- list()
    timeKernelMatSum <- list()
    for (i in 5:6){
        
        N <- seq(from = 256, to = 8192, length.out = 63)
        
        gridsizes <- as.integer((N +  tileWidth -1)/tileWidth);
        blocknumber <- gridsizes*gridsizes
        numberthreads <- threadsPerBlock * blocknumber;
        numberMultiplication <- 1;
        
        reads <- numberthreads*2
        tempOperationcycles <- ((numberMultiplication * 10) ) * numberthreads;
        CommGM <- ((numberthreads*2 - L1Effect - L2Effect + numberthreads)*latencyGlobalMemory + L1Effect*latencyL1 + L2Effect*latencyL2);
        
        if(apps[i] == "matrix_sum_normal" | lambda[k,i] == 0 ){
            lambda[k,i] <- 3.5
        }
        if(apps[i] ==  "matrix_sum_coalesced" | lambda[k,i] == 0 ){
            lambda[k,i] <- 14
        }
        
        timeKernel <- ( lambda[k,i]^-1*(tempOperationcycles + CommGM)/(flopsTheoreticalPeak[k,]*10^6));
        timeKernelMatSum[[apps[i]]] <- timeKernel
        SpeedupMatSum[[apps[i]]] <- timeKernel[1:length(TimeApp[[apps[i]]])]/TimeApp[[apps[i]]];
    }
    SpeedupMatSum
    
    SpeedupVecOp <- list()
    timeKernelVecOp <- list()
    for (i in 7:9){
        if (gpus[k,'gpu_name'] == "GTX-680"){
            N <- c(131072, 262144, 524288, 1048576, 2097152, seq(from = 4194304, to = 167772160, length.out = 40))
        }
        else {
            N <- c(131072, 262144, 524288, 1048576, 2097152, seq(from = 4194304, to = 268435456, length.out = 64))
        }
        if (apps[i] != "subSeqMax"){
            
            BlockSize <- tileWidth*tileWidth
            blocknumber <- (N+BlockSize-1) / BlockSize ;
            
            numberthreads <- threadsPerBlock * blocknumber;
            numberMultiplication <- 1;
            
            reads <- numberthreads*2
            
            tempOperationcycles <- ((numberMultiplication * 20) ) * numberthreads;
            CommGM <- ((numberthreads*2 - L1Effect - L2Effect + numberthreads)*latencyGlobalMemory + L1Effect*latencyL1 + L2Effect*latencyL2);
            
            if(apps[i] == "dotProd" | lambda[k,i] == 0 ){
                lambda[k,i] <- 22
            }
            if(apps[i] == "vectorAdd" | lambda[k,i] == 0 ){
                lambda[k,i] <- 15
            }
            
        } else {
            
            gridsize <- 32;
            blocksize <- 128
            
            numberthreads <- gridsize * blocksize;
            N_perBlock <- N/gridsize;
            N_perThread <- N_perBlock/blocksize;
            
            numberMultiplication <- 1;
            
            reads <- numberthreads*N_perThread;
            
            tempOperationcycles <- 100*numberthreads * N_perThread;
            CommGM <- ((numberthreads*N_perThread - L1Effect - L2Effect + numberthreads*5)*latencyGlobalMemory + L1Effect*latencyL1 + L2Effect*latencyL2);
            CommSM <- (numberthreads*N_perThread + numberthreads*5)*latencySharedMemory
            
            if(apps[i] == "subSeqMax" | lambda[k,i] == 0 ){
                lambda[k,i] <- 2.17
            }
        }
        timeKernel <- ( lambda[k,i]^-1*(tempOperationcycles + CommGM)/(flopsTheoreticalPeak[k,]*10^6));
        timeKernelVecOp[[apps[i]]] <- timeKernel
        SpeedupVecOp[[apps[i]]] <- timeKernel[1:length(TimeApp[[apps[i]]])]/TimeApp[[apps[i]]];
        
    }
    SpeedupVecOp
    
    matMul <- array(unlist(SpeedupMatMul,use.names = T))
    TkmatMul <- array(unlist(timeKernelMatMul,use.names = T))
    
    if (gpus[k,'gpu_name'] == "GTX-680"){
        N <- seq(from = 256, to = 4096, length.out = 16)
    } else {
        N <- seq(from = 256, to = 8192, length.out = 32)
    }
    namesMatMul <- c(rep("matMul_gpu",length(N)), rep("matMul_gpu_uncoalesced",length(N)),
                     rep("matMul_gpu_sharedmem_uncoalesced",length(N)), rep("matMul_gpu_sharedmem",length(N)))
    
    dfmatMul <- cbind(matMul, TkmatMul, namesMatMul, N)

    matSum <- array(unlist(SpeedupMatSum,use.names = T))
    TkmatSum <- array(unlist(timeKernelMatSum,use.names = T))
    N <- seq(from = 256, to = 8192, length.out = 63)
    namesmatSum <- c(rep("matrix_sum_normal",length(N)), rep("matrix_sum_coalesced",length(N)))
    
    dfmatSum <- cbind(matSum, TkmatSum, namesmatSum, N)
    
    matVecOp <- array(unlist(SpeedupVecOp,use.names = T))
    TkVecop <- array(unlist(timeKernelVecOp,use.names = T))
    if (gpus[k,'gpu_name'] == "GTX-680"){
        N <- c(131072, 262144, 524288, 1048576, 2097152, seq(from = 4194304, to = 167772160, length.out = 40))
    } else {
        N <- c(131072, 262144, 524288, 1048576, 2097152, seq(from = 4194304, to = 268435456, length.out = 64))
    }
    namesVecOp <-c(rep("dotProd",length(N)), rep("vectorAdd",length(N)),  rep("subSeqMax",length(N)))
    dfVecOp <- cbind(matVecOp, TkVecop, namesVecOp,N)
    
    allApp = rbind(dfmatMul,dfmatSum,dfVecOp)
    
    dfAllApp <- data.frame(Accuracy=allApp[,1], Tk=allApp[,2], Duration= array(unlist(TimeApp,use.names = F)), Apps=allApp[,3], Size=allApp[,4], GPUs=gpus[k,'gpu_name'])
    
    dataGPUsApps <- rbind(dfAllApp, dataGPUsApps)
    
}
View(dataGPUsApps)
    