# library("data.table")
# library("ff")
library("ggplot2")

dirpath <- "~/Dropbox/Doctorate/Theses/gpuperfpredict/"
setwd(paste(dirpath, sep = ""))

source("./R-code/include/common.R")
source("./R-code/include/sharedFunctions.R")

set.seed(5)

namesTraces <- read.csv("./data/tracesNames.csv",header = T, sep = ",")

tempFeatures <- data.frame()
for (kernelApp in c(6)) {
    tempApps <- data.frame()
    for (gpu in c(2:4, 8:9)) {
        tempAppGpu <- read.csv(paste("./Datasets/", names(kernelsDict[kernelApp]), "-", gpus[gpu,'gpu_name'], ".csv", sep=""))
        tempAppGpu[1] <- tempAppGpu$input.size.1
        tempAppGpu[2] <- tempAppGpu$input.size.2
        tempAppGpu[3] <- tempAppGpu$duration
        tempAppGpu[4] <- tempAppGpu$grid.x*tempAppGpu$grid.y
        tempAppGpu[5] <- tempAppGpu$block.x*tempAppGpu$block.y
        tempAppGpu[6] <- names(kernelsDict[kernelApp])
        tempAppGpu[7] <- gpu
        tempAppGpu <- tempAppGpu[1:7]
        names(tempAppGpu) <- c("input.size.1", "input.size.2", "duration", "threadsBlocks", "gridSize", "kernels", "gpu")
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

lambda <- matrix(nrow = NoGPU, ncol = 6, 0, dimnames = gpus['gpu_name'])
lambda[,1] <- c(0.022, 0.0225, 0.023, 0.022, 0.02, 0.015, 0.02, 0.016, 0.03)*280
lambda[,2] <- c(0.0075, 0.0085, 0.0085, 0.0085,0.007, 0.0055, 0.0065, 0.00575, 0.0105)*1000
lambda[,3] <- c(0.26, 0.35, 0.35,  0.35, 0.25, 0.4, 0.7, 0.45, 0.3)
lambda[,4] <- c(0.65, 1.25, 1.25,  1.25, 0.7, 2, 3.5, 2.5, 2)
lambda[,5] <- c(2.15, 2.25, 2.5, 2.25, 1.65, 3.25, 5, 3.75, 5.5 )
lambda[,6] <- c(8, 14, 14.5, 14, 8, 7, 8, 7, 25)
# lambda[,7] <- c(8.5,12, 12, 12, 12, 4, 7.5, 6.25, 7.5)

# lambda[,7] <- NULL
print(xtable(lambda, type = "latex"))

includeFile <- "~/Dropbox/Doctorate/Theses/gpuperfpredict/R-code/include/"
appAllKernel <- data.frame()
for (gpu in c(2:4, 8:9)) {
    # source(file = paste(includeFile, "Back-Propagation.R", sep = ""))
    # source(file = paste(includeFile, "Gaussian.R", sep = ""))
    # source(file = paste(includeFile, "Hearthwall.R", sep = ""))
    source(file = paste(includeFile, "Hotspot.R", sep = ""))
    # source(file = paste(includeFile, "Hotspot_3D.R", sep = ""))
}

appAllKernel$gpu <- factor(appAllKernel$gpu, levels = c("GTX-680", "Tesla-K40",  "Tesla-K20", "Titan", "Quadro",  "TitanX", "GTX-970", "GTX-980", "Tesla-P100"))


appAllKernel$kernels <- revalue(appAllKernel$kernels, c("bpnn_layerforward_CUDA"="BCK-1", "bpnn_adjust_weights_cuda"="BCK-2", 
                                          "Fan1"="GAU-1", "Fan2"="GAU-2",
                                          "kernel"="HTW", "calculate_temp"="HOT"))


Graph <- ggplot(data=appAllKernel, aes(x=gpu, y=accuracy, group=gpu, col=gpu)) + 
    geom_boxplot(size=1.5, outlier.size = 2.5) + scale_y_continuous(limits =  c(0, 2)) +
    stat_boxplot(geom ='errorbar')  +
    xlab(" ") + 
    theme_bw() +
    ggtitle("Accuracy Rodinia Kernels with the BSP-based Analytical model") +
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
    facet_wrap(~kernels, ncol=3, scales="fixed") +
    theme(strip.text = element_text(size=20))+
    scale_colour_grey()
figureFile <- includeFile <- "~/Dropbox/Doctorate/Theses/gpuperfpredict/"
ggsave(paste(figureFile, "./images/ResutAnalyticalModelRodinia.pdf",sep=""), Graph, device = pdf, height=10, width=16)
    
    Graph <- ggplot(data=appAllKernel, aes(x=gpu, y=accuracy, group=gpu, col=gpu)) +
      geom_line()   +
      xlab(" ") +
      theme_bw() +
      ggtitle("Analytical Model") +
      ylab(expression(paste("Accuracy ",T[k]/T[m] ))) +
      theme(plot.title = element_text(family = "Times", face="bold", size=10)) +
      theme(axis.title = element_text(family = "Times", face="bold", size=10)) +
      theme(axis.text  = element_text(family = "Times", face="bold", size=10, colour = "Black")) +
      theme(axis.text.x=element_blank()) +
      theme(legend.title  = element_text(family = "Times", face="bold", size=0)) +
      theme(legend.text  = element_text(family = "Times", face="bold", size=10)) +
      theme(legend.direction = "horizontal",
            legend.position = "bottom",
            legend.key=element_rect(size=1),
            legend.key.size = unit(1, "lines")) +
      facet_wrap(~kernels, ncol=1, scales="free")
    # theme(strip.text = element_text(size=20))
    ggsave(paste("./images/Analyticalmodel-Lines.pdf",sep=""), Graph, height=40, width=20, units="cm")
    
    
    lambda <- data.frame(lambda)
    colnames(lambda) <- names(kernelsDict)[1:6]
    lambda[-c(6), ]
    lambdaT <- data.frame()
    lambdaT <- rbind(lambdaT,data.frame(apps=rep("BCK-1"), lambdas=lambda$bpnn_layerforward_CUDA))
    lambdaT <- rbind(lambdaT,data.frame(apps=rep("BCK-2"), lambdas=lambda$bpnn_adjust_weights_cuda))
    lambdaT <- rbind(lambdaT,data.frame(apps=rep("GAU-1"), lambdas=lambda$Fan1))
    lambdaT <- rbind(lambdaT,data.frame(apps=rep("GAU-2"), lambdas=lambda$Fan2))
    lambdaT <- rbind(lambdaT,data.frame(apps=rep("HHWL"), lambdas=lambda$kernel))
    lambdaT <- rbind(lambdaT,data.frame(apps=rep("HOT"), lambdas=lambda$calculate_temp))
    
    Graph <- ggplot(data=lambdaT, aes(x=apps, y=lambdas, group=apps, col=apps)) + 
        scale_y_continuous(breaks = round(seq(0, max(lambdaT$lambdas), by = 10),1)) +
        geom_boxplot(size=1.5, outlier.size = 2.5) + 
        theme_bw() +
        stat_boxplot(geom ='errorbar') +
        xlab("") + 
        ggtitle("Lambda Values of Rodinia Benchmarking Suite CUDA Kernels") +
        theme(plot.title = element_text(hjust = 0.5)) +
        ylab("Lambda Values") +
        theme(plot.title = element_text(family = "Times", face="bold", size=30)) +
        theme(axis.title = element_text(family = "Times", face="bold", size=30)) +
        theme(axis.text  = element_text(family = "Times", face="bold", size=20, colour = "Black")) +
        theme(legend.position = "none") +
        theme(strip.text = element_text(size=20))+
        scale_colour_grey()
    # Graph
    ggsave(paste("./images/LambdaAnalyticalModel-Rodinia.pdf",sep=""), Graph, device = pdf, height=10, width=16)
    
    write.csv(appAllKernel, file = paste("./Results/BSP-based-model-Rodinia.csv", sep=""))
    