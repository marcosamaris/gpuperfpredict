library(ggplot2)
library(reshape2)

cbbPalette <- gray(1:9/ 12)#c("red", "blue", "darkgray", "orange","black","brown", "lightblue","violet")
dirpath <- "~/Dropbox/Doctorate/Results/2016/svm-gpuperf/Analytical-model/"
setwd(paste(dirpath, sep=""))

gpus <- read.table("../ML-model/deviceInfo.csv", sep=",", header=T)
NoGPU <- dim(gpus)[1]

apps <- c("matMul_gpu_uncoalesced","matMul_gpu", "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem",
         "matrix_sum_normal", "matrix_sum_coalesced", 
         "dotProd", "vectorAdd",  "subSeqMax")

flopsTheoreticalPeak <- gpus['max_clock_rate']*gpus['num_of_cores']
lambda <- matrix(nrow = NoGPU,ncol = length(apps), 0)

lambdaK40 <- c(4.30, 20, 19.00, 65.00,  2.50,  9.50,  9.00, 10.00,  0.48)
lambdaK40L1 <- c(3.5,   20, 19,   65, 2.75,  9.5,    9,   10, 0.48)

lambdaTitan <- c(4.25,  21,   17,  50, 2.50, 10.0,  9.5,   12, 0.48)
lambdaK20 <- c(4.50,   21,   18,   52, 2.50,  9.0,  9.5,   10, 0.50)

lambda[1,] <- lambdaK40
lambda[2,] <- lambdaK40L1

lambda[4,] <- lambdaTitan
lambda[5,] <- lambdaK20


dataGPUsApps <- data.frame()

for (k in 1:3){

    TimeApp <- list()
    for (i in 1:length(apps)){
        if (gpus[k,'gpu_name'] == "Tesla-K40-UsingL1" | gpus[k,'gpu_name'] == "GTX-680"){
            print("Run 1")
            data <- read.table(paste("../data/", gpus[k,'gpu_name'],"/run_1/", apps[i], "-kernel-traces.csv", sep=""), sep=",", header=F)
        } else {
            data <- read.table(paste("../data/", gpus[k,'gpu_name'],"/run_0/", apps[i], "-kernel-traces.csv", sep=""), sep=",", header=F)
            print("Run 0")
        }
      TimeApp[apps[i]] <- data['V3']
    }
    
    latencySharedMemory <- 5; #Cycles per processor
    latencyGlobalMemory <- latencySharedMemory* 100; #Cycles per processor
    
    latencyL1 <- latencySharedMemory; #Cycles per processor
    latencyL2 <- latencyGlobalMemory*0.5; #Cycles per processor
    
    SpeedupMatMul <- list()
    for (i in 1:4){
        N <- seq(from = 256, to = 8192, length.out = 32)
        
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
            lambda[k,i] <- 4.5
        }
        if (apps[i] == "matMul_gpu" | lambda[k,i] == 0 ){
            lambda[k,i] <- 21
        }
        if (apps[i] == "matMul_gpu_sharedmem_uncoalesced" | lambda[k,i] == 0 ){
            lambda[k,i] <- 18
        }
        if (apps[i] == "matMul_gpu_sharedmem" | lambda[k,i] == 0 ){
            lambda[k,i] <- 52
        }

        timeKernel <- ( lambda[k,i]^-1*(timeComputationKernel + CommGM)/(flopsTheoreticalPeak[k,]*10^6));
        SpeedupMatMul[[apps[i]]] <- timeKernel[1:length(TimeApp[[apps[i]]])]/TimeApp[[apps[i]]];
    }
    SpeedupMatMul
    
    SpeedupMatSum <- list()
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
            lambda[k,i] <- 2.5
        }
        if(apps[i] ==  "matrix_sum_coalesced" | lambda[k,i] == 0 ){
            lambda[k,i] <- 9
        }
        timeKernel <- ( lambda[k,i]^-1*(tempOperationcycles + CommGM)/(flopsTheoreticalPeak[k,]*10^6));
        SpeedupMatSum[[apps[i]]] <- timeKernel[1:63]/TimeApp[[apps[i]]];
    }
    SpeedupMatSum
    
    SpeedupVecOp <- list()
    for (i in 7:9){
        if (apps[i] != "subSeqMax"){
            N <- c(131072, 262144, 524288, 1048576, 2097152, seq(from = 4194304, to = 268435456, length.out = 64))
            BlockSize <- tileWidth*tileWidth
            blocknumber <- (N+BlockSize-1) / BlockSize ;
            
            numberthreads <- threadsPerBlock * blocknumber;
            numberMultiplication <- 1;
            
            reads <- numberthreads*2
            
            tempOperationcycles <- ((numberMultiplication * 20) ) * numberthreads;
            CommGM <- ((numberthreads*2 - L1Effect - L2Effect + numberthreads)*latencyGlobalMemory + L1Effect*latencyL1 + L2Effect*latencyL2);
            
            if(apps[i] == "dotProd" | lambda[k,i] == 0 ){
                lambda[k,i] <- 9.5
            }
            if(apps[i] == "vectorAdd" | lambda[k,i] == 0 ){
                lambda[k,i] <- 10
            }
            timeKernel <- ( lambda[k,i]^-1*(tempOperationcycles + CommGM)/(flopsTheoreticalPeak[k,]*10^6));
            SpeedupVecOp[[apps[i]]] <- timeKernel[1:69]/TimeApp[[apps[i]]];
        } else {
            N <- c(131072, 262144, 524288, 1048576, 2097152, seq(from = 4194304, to = 268435456, length.out = 64))
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
                lambda[k,i] <- .50
            }
            timeKernel <- ( lambda[k,i]^-1*(tempOperationcycles + CommGM)/(flopsTheoreticalPeak[k,]*10^6));
            SpeedupVecOp[[apps[i]]] <- timeKernel[1:69]/TimeApp[[apps[i]]];
        }
    }
    SpeedupVecOp
    
    matMul <- array(unlist(SpeedupMatMul,use.names = T))
    namesMatMul <- c(rep("matMul_gpu",32), rep("matMul_gpu_uncoalesced",32),rep("matMul_gpu_sharedmem_uncoalesced",32), rep("matMul_gpu_sharedmem",32))
    N <- seq(from = 256, to = 8192, length.out = 32)
    dfmatMul <- cbind(matMul, namesMatMul, N)

    matSum <- array(unlist(SpeedupMatSum,use.names = T))
    namesmatSum <- c(rep("matrix_sum_normal",63), rep("matrix_sum_coalesced",63))
    N <- seq(from = 256, to = 8192, length.out = 63)
    dfmatSum <- cbind(matSum, namesmatSum,N)
    
    matVecOp <- array(unlist(SpeedupVecOp,use.names = T))
    namesVecOp <-c(rep("dotProd",69), rep("vectorAdd",69),  rep("subSeqMax",69))
    N <- c(131072, 262144, 524288, 1048576, 2097152, seq(from = 4194304, to = 268435456, length.out = 64))
    dfVecOp <- cbind(matVecOp, namesVecOp,N)
    
    allApp = rbind(dfmatMul,dfmatSum,dfVecOp)
    
    dfAllApp <- data.frame(Accuracy=allApp[,1], Apps=allApp[,2], Apps=allApp[,3], gpu=gpus[k,'gpu_name'])
    
    
    
    dataGPUsApps <- rbind(dfAllApp, dataGPUsApps)
    
}
View(dataGPUsApps)
    