library(ggplot2)
library(reshape2)

cbbPalette <- gray(1:9/ 12)#c("red", "blue", "darkgray", "orange","black","brown", "lightblue","violet")
dirpath <- "~/Doctorate/svm-gpuperf/"
setwd(paste(dirpath, sep=""))

gpus <- read.table("./ML-model/deviceInfo_L1disabled.csv", sep=",", header=T)
NoGPU <- dim(gpus)[1]

apps <- c("matMul_gpu_uncoalesced","matMul_gpu", "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem",
         "matrix_sum_normal", "matrix_sum_coalesced", 
         "dotProd", "vectorAdd",  "subSeqMax")

flopsTheoreticalPeak <- gpus['max_clock_rate']*gpus['num_of_cores']
lambda <- matrix(nrow = NoGPU, ncol = length(apps), 0, dimnames = gpus['gpu_name'])

lambdaK40 <- c(4.30, 20, 19, 65 ,  2.50,  9.50,  9 , 10,  0.48)
lambdaK40L1 <- c(3.5,   20, 19,   65, 2.75,  9.5,    9,   10, 0.48)
lambdaGTX680 <- c(4.5,   19,   20,   68, 1.5,  9.25, 14, 11, 0.68)
lambdaTitan <- c(4.25,  21,   17,  50, 2.5, 10,  9.5,   12, 0.48)
lambdaK20 <- c(4.5,   21,   18,   52, 2.5,  9,  10, 10, 0.55)
lambdaQ <- c(4.75,   20,   20,   64, 1,  8.25, 11,  9.5, 0.55)
lambdaQL1 <- c(3.35, 20 , 25 , 64,  1.75,  8.5, 11 ,  9.50,  0.5)
lambdaTitanX <- c(9.5,   36,   36,  110, 3,  9.50,  8,  9.75, 0.95)
lambdaTitanBlack <- c(3.5,   17,   17,   52, 1.75,  7.5,  7.25,  8.5, 0.35)
lambdaTitanBlackL1 <- c(2.25,   17,   18,   52, 2,  7.5,  7.25,  8.5, 0.35)
lambdaGTX980 <- c(13,   44,   46,   120, 3.25,  9.5,  9,  9.5, 1.5)
lambdaGTX970 <- c(7,  26,  24, 80,   1.75,   10,  7,   6.5,   1.15)
lambdaGTX750 <- c(10,   52,   40,  138, 3.5, 14, 25, 15, 2)

lambda[1,] <- lambdaK40
lambda[2,] <- lambdaGTX680
lambda[3,] <- lambdaTitan
lambda[4,] <- lambdaK20
lambda[5,] <- lambdaQ
lambda[6,] <- lambdaTitanX
lambda[7,] <- lambdaTitanBlack
lambda[8,] <- lambdaGTX980
lambda[9,] <- lambdaGTX970
lambda[10,] <- lambdaGTX750

#library(xtable)
#dflambda <- data.frame(lambda)
#xtable(lambda[1:10,])

dataGPUsApps <- data.frame()

noSamples <- 10
for (k in 5:6){

    TimeApp <- list()
    for (i in 1:length(apps)){
        data <- 0; Temp <- 0
        print(paste(" Loaded ", gpus[k,'gpu_name'], "/", apps[i], sep=""))
            for (j in 1:noSamples){
                temp <- read.table(paste("./data/", gpus[k,'gpu_name'],"/traces/run_", j, "/", apps[i], "-kernel-traces.csv", sep=""), sep=",", header=F)["V3"]
                data <- data + temp
            }
        
      TimeApp[apps[i]] <- data/noSamples
    }
    
    latencySharedMemory <- 5; #Cycles per processor
    latencyGlobalMemory <- latencySharedMemory* 100; #Cycles per processor
    
    latencyL1 <- latencySharedMemory; #Cycles per processor
    latencyL2 <- latencyGlobalMemory*0.5; #Cycles per processor
    
    SpeedupMatMul <- list()
    timeKernelMatMul <- list()
    for (i in 1:4){
        nN <- 9:13
        N <- 2^nN
        
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
#         if (apps[i] == "matMul_gpu_uncoalesced" & lambda[k,i] == 0 ){
#             lambda[k,i] <- 13
#         }
#         if (apps[i] == "matMul_gpu" & lambda[k,i] == 0 ){
#             lambda[k,i] <- 42
#         }
#         if (apps[i] == "matMul_gpu_sharedmem_uncoalesced" & lambda[k,i] == 0 ){
#             lambda[k,i] <- 38
#         }
#         if (apps[i] == "matMul_gpu_sharedmem" & lambda[k,i] == 0 ){
#             lambda[k,i] <- 120
#         }

        timeKernel <- ( lambda[k,i]^-1*(timeComputationKernel + CommGM)/(flopsTheoreticalPeak[k,]*10^6));
        timeKernelMatMul[[apps[i]]] <- timeKernel
        SpeedupMatMul[[apps[i]]] <- timeKernel[1:length(TimeApp[[apps[i]]])]/TimeApp[[apps[i]]];
    }
    SpeedupMatMul
    
    SpeedupMatSum <- list()
    timeKernelMatSum <- list()
    for (i in 5:6){
        
        nN <- 9:13
        N <- 2^nN
        
        
        gridsizes <- as.integer((N +  tileWidth -1)/tileWidth);
        blocknumber <- gridsizes*gridsizes
        numberthreads <- threadsPerBlock * blocknumber;
        numberMultiplication <- 1;
        
        reads <- numberthreads*2
        tempOperationcycles <- ((numberMultiplication * 10) ) * numberthreads;
        CommGM <- ((numberthreads*2 - L1Effect - L2Effect + numberthreads)*latencyGlobalMemory + L1Effect*latencyL1 + L2Effect*latencyL2);
        
#         if(apps[i] == "matrix_sum_normal" & lambda[k,i] == 0 ){
#             lambda[k,i] <- 3.5
#         }
#         if(apps[i] ==  "matrix_sum_coalesced" & lambda[k,i] == 0 ){
#             lambda[k,i] <- 14
#         }
        
        timeKernel <- ( lambda[k,i]^-1*(tempOperationcycles + CommGM)/(flopsTheoreticalPeak[k,]*10^6));
        timeKernelMatSum[[apps[i]]] <- timeKernel
        SpeedupMatSum[[apps[i]]] <- timeKernel[1:length(TimeApp[[apps[i]]])]/TimeApp[[apps[i]]];
    }
    SpeedupMatSum
    
    SpeedupVecOp <- list()
    timeKernelVecOp <- list()
    for (i in 7:9){
        if (gpus[k,'gpu_name'] == "GTX-750"){
            nN <- 18:27
            N <- 2^nN
        }
        else {
            nN <- 18:27
            N <- 2^nN
        }
        if (apps[i] != "subSeqMax"){
            
            BlockSize <- tileWidth*tileWidth
            blocknumber <- (N+BlockSize-1) / BlockSize ;
            
            numberthreads <- threadsPerBlock * blocknumber;
            numberMultiplication <- 1;
            
            reads <- numberthreads*2
            
            tempOperationcycles <- ((numberMultiplication * 20) ) * numberthreads;
            CommGM <- ((numberthreads*2 - L1Effect - L2Effect + numberthreads)*latencyGlobalMemory + L1Effect*latencyL1 + L2Effect*latencyL2);
            
#             if(apps[i] == "dotProd" & lambda[k,i] == 0 ){
#                 lambda[k,i] <- 22
#             }
#             if(apps[i] == "vectorAdd" & lambda[k,i] == 0 ){
#                 lambda[k,i] <- 15
#             }
            
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
            
#             if(apps[i] == "subSeqMax" & lambda[k,i] == 0 ){
#                 lambda[k,i] <- 2.17
#             }
        }
        timeKernel <- ( lambda[k,i]^-1*(tempOperationcycles + CommGM)/(flopsTheoreticalPeak[k,]*10^6));
        timeKernelVecOp[[apps[i]]] <- timeKernel
        SpeedupVecOp[[apps[i]]] <- timeKernel[1:length(TimeApp[[apps[i]]])]/TimeApp[[apps[i]]];
        
    }
    SpeedupVecOp
    
    matMul <- array(unlist(SpeedupMatMul,use.names = T))
    TkmatMul <- array(unlist(timeKernelMatMul,use.names = T))
    
    nN <- 9:13
    N <- 2^nN
    
    namesMatMul <- c(rep("matMul_gpu_uncoalesced",length(N)), rep("matMul_gpu",length(N)),
                     rep("matMul_gpu_sharedmem_uncoalesced",length(N)), rep("matMul_gpu_sharedmem",length(N)))
    
    dfmatMul <- cbind(matMul, TkmatMul, namesMatMul, N)

    matSum <- array(unlist(SpeedupMatSum,use.names = T))
    TkmatSum <- array(unlist(timeKernelMatSum,use.names = T))
    nN <- 9:13
    N <- 2^nN
    
    namesmatSum <- c(rep("matrix_sum_normal",length(N)), rep("matrix_sum_coalesced",length(N)))
    
    dfmatSum <- cbind(matSum, TkmatSum, namesmatSum, N)
    
    matVecOp <- array(unlist(SpeedupVecOp,use.names = T))
    TkVecop <- array(unlist(timeKernelVecOp,use.names = T))
    
    nN <- 18:27
    N <- 2^nN
    
    namesVecOp <-c(rep("dotProd",length(N)), rep("vectorAdd",length(N)),  rep("subSeqMax",length(N)))
    dfVecOp <- cbind(matVecOp, TkVecop, namesVecOp,N)
    
    allApp = rbind(dfmatMul,dfmatSum,dfVecOp)
    
    dfAllApp <- data.frame(Accuracy=allApp[,1], Tk=allApp[,2], Duration= array(unlist(TimeApp,use.names = F)), Apps=allApp[,3], Size=allApp[,4], GPUs=gpus[k,'gpu_name'], CC= gpus[k,'compute_version'])
    
    dataGPUsApps <- rbind(dfAllApp, dataGPUsApps)
    
}
#View(dataGPUsApps)
dataTemp <- data.frame()

dataTemp <- dataGPUsApps

# dataTemp <- dataTemp[dataTemp$GPUs != "GTX-680" & dataTemp$GPUs != "Quadro",]
#dataTemp <- dataGPUsApps[(dataGPUsApps$Apps != "matrix_sum_normal")]
#dataTemp$apps <- dataTemp[dataTemp$Apps != "matrix_sum_normal",]

dataTemp$Apps <- factor(dataTemp$Apps, levels =  c("matMul_gpu_uncoalesced","matMul_gpu", "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem",
                                                   "matrix_sum_normal", "matrix_sum_coalesced", 
                                                 "dotProd", "vectorAdd",  "subSeqMax"))

dataTemp$GPUs <- factor(dataTemp$GPUs, levels = c("Tesla-K40",  "Tesla-K20", "Quadro", "Titan", "TitanBlack", "TitanX", "GTX-680","GTX-980",    "GTX-970",    "GTX-750"))
print(levels(dataTemp$Apps))

dataTemp$Size <- as.numeric(as.character(dataTemp$Size))
dataTemp$Accuracy <- as.numeric(as.character(dataTemp$Accuracy))

#View(dataTemp)

Graph <- ggplot(data=dataTemp, aes(x=Size, y=Accuracy, group=GPUs, color = GPUs)) + 
    geom_line(size=1) +
    xlab("Size of elements to compute") + 
    ylab(expression(paste("Accuracy ",T[k]/T[m] ))) +
    theme(axis.title = element_text(family = "Trebuchet MS", face="bold", size=22)) +
    theme(axis.text  = element_text(family = "Trebuchet MS", face="bold", size=6)) +
    theme(legend.title  = element_text(family = "Trebuchet MS", face="bold", size=16)) +
    theme(legend.text  = element_text(family = "Trebuchet MS", face="bold", size=16)) +
    facet_wrap(~Apps, ncol=3, scales="free_x") +
    theme(strip.text.x = element_text(size = 18, colour = "Black")) +
    scale_colour_grey()

Graph
ggsave(paste("./images/Graph-No-GTX680-Quadro.png",sep=""), Graph,height=10, width=16)

