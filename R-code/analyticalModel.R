
library(ggplot2)
library(reshape2)
library(plyr)

cbbPalette <- gray(1:9/ 12)#c("red", "blue", "darkgray", "orange","black","brown", "lightblue","violet")
dirpath <- "~/Dropbox/Doctorate/Theses/gpuperfpredict/"
setwd(paste(dirpath, sep=""))

gpus <- read.table("./Datasets/deviceInfo.csv", sep=",", header=T)
NoGPU <- dim(gpus)[1]

apps <- c("matMul_gpu_uncoalesced","matMul_gpu", "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem",
         "matrix_sum_normal", "matrix_sum_coalesced", 
         "dotProd", "vectorAdd",  "subSeqMax")

flopsTheoreticalPeak <- gpus['max_clock_rate']*gpus['num_of_cores']
lambda <- matrix(nrow = NoGPU, ncol = length(apps), 0, dimnames = gpus['gpu_name'])

lambdaGTX680 <- c(4.5,   19,   20,   68, 1.5,  9.25, 14, 11, 0.6)
lambdaK20 <- c(4.75,   21,   18,   55, 2.5,  9,  6, 10, 0.55)
lambdaK40 <- c(4.75, 20, 19, 65 ,  2.50,  9.50,  5.5 , 10,  0.5)
lambdaTitan <- c(4.5,  21,   17,  55, 2.5, 10,  5.5,   12, 0.5)
lambdaQ <- c(4.75,   20,   20,   64, 1,  8.25, 6,  9.5, 0.55)
lambdaTitanX <- c(9.5,   36,   36,  110, 3,  9.50,  8,  9.75, 0.95)
lambdaGTX970 <- c(13.5,   50,   46,   140, 3.25,  9.5,  7,  10.5, 2.25)
lambdaGTX980 <- c(13.5,   44,   40,   120, 3,  8.5,  7,  8.5, 1.65)
lambdaP100 <- c(10,   52,   40,  138, 3.5, 14, 25, 15, 2)

lambda[1,] <- lambdaGTX680
lambda[2,] <- lambdaK40
lambda[3,] <- lambdaK20
lambda[4,] <- lambdaTitan
lambda[5,] <- lambdaQ
lambda[6,] <- lambdaTitanX
lambda[7,] <- lambdaGTX970
lambda[8,] <- lambdaGTX980
lambda[9,] <- lambdaP100


dataGPUsApps <- data.frame()

noSamples <- 10
for (k in c(2:4, 7:8)){

    TimeApp <- list()
    for (i in 1:length(apps)){
        data <- 0; Temp <- 0
        print(paste(" Loaded ", gpus[k,'gpu_name'], "/", apps[i], sep=""))
                temp <- read.table(paste("./data/", gpus[k,'gpu_name'],"/block_16/", apps[i], "-kernel-traces.csv", sep=""), sep=",", header=FALSE)["V3"]
                
      TimeApp[apps[i]] <- temp
    }
    
    latencySharedMemory <- 5; #Cycles per processor
    latencyGlobalMemory <- latencySharedMemory* 100; #Cycles per processor
    
    latencyL1 <- latencySharedMemory; #Cycles per processor
    latencyL2 <- latencyGlobalMemory*0.5; #Cycles per processor
    
    SpeedupMatMul <- list()
    timeKernelMatMul <- list()
    for (i in 1:4){
        nN <- 9:13
        N <- seq(256,8192, 256)
        
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
        
        timeKernel <- ( lambda[k,i]^-1*(timeComputationKernel + CommGM)/(flopsTheoreticalPeak[k,]*10^6));
        timeKernelMatMul[[apps[i]]] <- timeKernel
        SpeedupMatMul[[apps[i]]] <- timeKernel[1:length(TimeApp[[apps[i]]])]/TimeApp[[apps[i]]];
    }
    SpeedupMatMul
    
    SpeedupMatSum <- list()
    timeKernelMatSum <- list()
    for (i in 5:6){
        
        nN <- 9:13
        N <- seq(256,8192,256)
        
        
        gridsizes <- as.integer((N +  tileWidth -1)/tileWidth);
        blocknumber <- gridsizes*gridsizes
        numberthreads <- threadsPerBlock * blocknumber;
        numberMultiplication <- 1;
        
        reads <- numberthreads*2
        tempOperationcycles <- ((numberMultiplication * 10) ) * numberthreads;
        CommGM <- ((numberthreads*2 - L1Effect - L2Effect + numberthreads)*latencyGlobalMemory + L1Effect*latencyL1 + L2Effect*latencyL2);
        
        timeKernel <- ( lambda[k,i]^-1*(tempOperationcycles + CommGM)/(flopsTheoreticalPeak[k,]*10^6));
        timeKernelMatSum[[apps[i]]] <- timeKernel
        SpeedupMatSum[[apps[i]]] <- timeKernel[1:length(TimeApp[[apps[i]]])]/TimeApp[[apps[i]]];
    }
    SpeedupMatSum
    
    SpeedupVecOp <- list()
    timeKernelVecOp <- list()
    for (i in 7:9){
      if (gpus[k,'gpu_name'] == "GTX-680" ){
        nN <- 17:21
        N <- c(2^nN, seq(2^22, 167772160, 2^22))
      } else {
        nN <- 17:21
        N <- c(2^nN, seq(2^22, 268435456, 2^22))
      }
        if (apps[i] != "subSeqMax"){
            
            BlockSize <- tileWidth*tileWidth
            blocknumber <- (N+BlockSize-1) / BlockSize ;
            
            numberthreads <- threadsPerBlock * blocknumber;
            numberMultiplication <- 1;
            
            reads <- numberthreads*2
            
            tempOperationcycles <- ((numberMultiplication * 20) ) * numberthreads;
            CommGM <- ((numberthreads*2 - L1Effect - L2Effect + numberthreads)*latencyGlobalMemory + L1Effect*latencyL1 + L2Effect*latencyL2);
            
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
            
        }
        timeKernel <- ( lambda[k,i]^-1*(tempOperationcycles + CommGM)/(flopsTheoreticalPeak[k,]*10^6));
        timeKernelVecOp[[apps[i]]] <- timeKernel
        SpeedupVecOp[[apps[i]]] <- timeKernel[1:length(TimeApp[[apps[i]]])]/TimeApp[[apps[i]]];
        
        # SpeedupVecOp[[apps[i]]] <- na.omit(SpeedupVecOp[[apps[i]]])
        
    }
    SpeedupVecOp
    
    
    matMul <- array(unlist(SpeedupMatMul,use.names = T))
    TkmatMul <- array(unlist(timeKernelMatMul,use.names = T))
    
    N <- seq(256,8192,256)
    
    namesMatMul <- c(rep("matMul_gpu_uncoalesced",length(N)), rep("matMul_gpu",length(N)),
                     rep("matMul_gpu_sharedmem_uncoalesced",length(N)), rep("matMul_gpu_sharedmem",length(N)))
    
    dfmatMul <- cbind(matMul, TkmatMul, namesMatMul, N)

    matSum <- array(unlist(SpeedupMatSum,use.names = T))
    TkmatSum <- array(unlist(timeKernelMatSum,use.names = T))
    
    N <- seq(256,8192,256)
    
    namesmatSum <- c(rep("matrix_sum_normal",length(N)), rep("matrix_sum_coalesced",length(N)))
    
    dfmatSum <- cbind(matSum, TkmatSum, namesmatSum, N)
    
    matVecOp <- array(unlist(SpeedupVecOp,use.names = T))
    TkVecop <- array(unlist(timeKernelVecOp,use.names = T))
    
    if (gpus[k,'gpu_name'] == "GTX-680" ){
      nN <- 17:21
      N <- c(2^nN, seq(2^22, 167772160, 2^22))
    } else {
      nN <- 17:21
      N <- c(2^nN, seq(2^22, 268435456, 2^22))
    }
    
    namesVecOp <-c(rep("dotProd",length(N)), rep("vectorAdd",length(N)),  rep("subSeqMax",length(N)))
    dfVecOp <- cbind(matVecOp, TkVecop, namesVecOp, N)
    
    allApp = rbind(dfmatMul,dfmatSum,dfVecOp)
    
    dfAllApp <- data.frame(Gpus=gpus[k,'gpu_name'], Apps=allApp[,3], InputSize=allApp[,4], ThreadBlock=0, Measured= array(unlist(TimeApp,use.names = F)), Predicted=allApp[,2], accuracy=allApp[,1], Min=0, max=0, Mean=0, Median=0, SD=0, mse=0, mae=0, mape=0)
    
    dataGPUsApps <- rbind(dfAllApp, dataGPUsApps)
    
}

dataTemp <- data.frame()

dataTemp <- dataGPUsApps

dataTemp$Apps <- factor(dataTemp$Apps, levels =  c("matMul_gpu_uncoalesced","matMul_gpu", "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem",
                                                   "matrix_sum_normal", "matrix_sum_coalesced", 
                                                 "dotProd", "vectorAdd",  "subSeqMax"))

dataTemp$Apps <- revalue(dataTemp$Apps, c("matMul_gpu_uncoalesced"="MMGU", "matMul_gpu"="MMGC", 
                         "matMul_gpu_sharedmem_uncoalesced"="MMSU", "matMul_gpu_sharedmem"="MMSC",
                         "matrix_sum_normal"="MAU", "matrix_sum_coalesced"="MAC", "dotProd" = "dotP", "vectorAdd" = "vAdd", "subSeqMax" = "MSA"))

dataTemp$Gpus <- factor(dataTemp$Gpus, levels = c("Tesla-K20", "Tesla-K40", "Quadro", "Titan", "TitanBlack", "TitanX", "GTX-680", "GTX-970", "GTX-980",        "GTX-750"))

dataTemp$InputSize <- as.numeric(as.character(dataTemp$InputSize))
dataTemp$accuracy <- as.numeric(as.character(dataTemp$accuracy))

dataTemp$mape <- mean(abs(dataTemp$Predicted - dataTemp$Measured)/abs(dataTemp$Measured))*100

Result_AM <- dataTemp
Graph <- ggplot(data=dataTemp, aes(x=Gpus, y=accuracy, group=Gpus, col=Gpus)) + 
    geom_boxplot(size=2, outlier.size = 2.5) + scale_y_continuous(limits =  c(0, 2)) +
    stat_boxplot(geom ='errorbar')  +
    xlab(" ") + 
    theme_bw() +
    ggtitle("Accuracy Vector/Matrix Kernels of the BSP-based Analytical model") +
    theme(plot.title = element_text(hjust = 0.5)) +
    ylab(expression(paste("Accuracy ",T[k]/T[m] ))) +
    theme(plot.title = element_text(family = "Times", face="bold", size=30)) +
    theme(axis.title = element_text(family = "Times", face="bold", size=20)) +
    theme(axis.text  = element_text(family = "Times", face="bold", size=20, colour = "Black")) +
    theme(axis.text.x=element_blank()) +
    theme(legend.title  = element_text(family = "Times", face="bold", size=0)) +
    theme(legend.text  = element_text(family = "Times", face="bold", size=20)) +
    theme(legend.direction = "horizontal", 
          legend.position = "bottom",
          legend.key=element_rect(size=5),
          legend.key.size = unit(5, "lines")) +
    # facet_grid(.~Apps, scales="fixed") 
    facet_wrap(~Apps, ncol=3, scales="fixed") +
    theme(strip.text = element_text(size=20))+
    scale_colour_grey()


ggsave(paste("./images/ResutAnalyticalModel.pdf",sep=""), Graph, device = pdf, height=10, width=16)
# ggsave(paste("./images/ResultModel/ResutAnalyticalModel.png",sep=""), Graph,height=10, width=16)


lambda <- data.frame(lambda)
colnames(lambda) <- apps
lambda[-c(7), ]
lambdaT <- data.frame()
lambdaT <- rbind(lambdaT,data.frame(apps=rep("MMGU"), lambdas=lambda$matMul_gpu_uncoalesced))
lambdaT <- rbind(lambdaT,data.frame(apps=rep("MMGC"), lambdas=lambda$matMul_gpu))
lambdaT <- rbind(lambdaT,data.frame(apps=rep("MMSU"), lambdas=lambda$matMul_gpu_sharedmem_uncoalesced))
lambdaT <- rbind(lambdaT,data.frame(apps=rep("MMSC"), lambdas=lambda$matMul_gpu_sharedmem))
lambdaT <- rbind(lambdaT,data.frame(apps=rep("MAU"), lambdas=lambda$matrix_sum_normal))
lambdaT <- rbind(lambdaT,data.frame(apps=rep("MAC"), lambdas=lambda$matrix_sum_coalesced))
lambdaT <- rbind(lambdaT,data.frame(apps=rep("dotP"), lambdas=lambda$dotProd))
lambdaT <- rbind(lambdaT,data.frame(apps=rep("vAdd"), lambdas=lambda$vectorAdd))
lambdaT <- rbind(lambdaT,data.frame(apps=rep("MSA"), lambdas=lambda$subSeqMax))

Graph <- ggplot(data=lambdaT, aes(x=apps, y=lambdas, group=apps, col=apps)) + 
    scale_y_continuous(breaks = round(seq(0, max(lambdaT$lambdas), by = 10),1)) +
    geom_boxplot(size=1.5, outlier.size = 2.5) + 
    theme_bw() +
    stat_boxplot(geom ='errorbar') +
    xlab(" ") + 
    ggtitle("Lambda Values of each one of the Applications") +
    theme(plot.title = element_text(hjust = 0.5)) +
    ylab("Lambda Values") +
    theme(plot.title = element_text(family = "Times", face="bold", size=30)) +
    theme(axis.title = element_text(family = "Times", face="bold", size=30)) +
    theme(axis.text  = element_text(family = "Times", face="bold", size=20, colour = "Black")) +
    theme(legend.position = "none") +
    theme(strip.text = element_text(size=20))+
    scale_colour_grey()
# Graph
ggsave(paste("./images/LambdaAnalyticalModel-NCA.pdf",sep=""), Graph, device = pdf, height=10, width=16)

write.csv(dataTemp, file = paste("./Results/BSP-based-model-NCA.csv", sep=""))
