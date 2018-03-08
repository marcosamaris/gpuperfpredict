library("randomForest")
library("plyr")
library("corrplot")
library("e1071")
library("ggplot2")
library("data.table")
library("cluster")
library("dendextend")

dirpath <- "~/Dropbox/Doctorate/Theses/gpuperfpredict/"
setwd(paste(dirpath, sep=""))

source("./R-code/include/common.R")
source("./R-code/include/sharedFunctions.R")

set.seed(5)

NroSamples <- c(57,57, rep(100, 11))
tempRodinia <- data.frame()
for(gpu in c(1:6, 7:9)) {
  for(kernelApp in c(1:6, 9:13)){
    tempAppGpu <- data.frame(cbind(fread(file = paste("./datasets/",names(kernelsDict[kernelApp]), "-", 
                                                      gpus[gpu,'gpu_name'], ".csv", sep=""),check.names = TRUE),gpus[gpu,] ))        
    tempRodinia <- rbind(tempRodinia, tempAppGpu[sample(nrow(tempAppGpu), NroSamples[kernelApp]),])
  }
}

DataAppGPU <- read.csv(file = paste("./datasets/All-App-GPU.csv", sep = ""))
DataAppGPU$input.size.2 <- 0

DataAppGPU$X <- NULL
DataAppGPU$kernel <- NULL
DataAppGPU <- setnames(DataAppGPU, old=c("input_size", 
                                         "grid_x", "grid_y", "block_x", "block_y",
                                         "registers_per_thread", "static_smem", "AppName","AppId"), 
                       new=c( "input.size.1", 
                              "grid.x", "grid.y", "block.x", "block.y",
                              "registers.per.thread", "static.smem", "name", "kernel"))

 DataAppGPU <- DataAppGPU[DataAppGPU$block.x %in% c(16, 128, 256),]
DataAppGPU$kernel <- DataAppGPU$kernel + 13

tempRodinia$X <- NULL
tempRodinia$V1 <- NULL
tempRodinia$l1.shared_memory_utilization <- NULL
tempRodinia$gpu_name.1 <- NULL

tempFeatures <- rbind(DataAppGPU[c(intersect(names(tempRodinia), names(DataAppGPU)))],tempRodinia)
tempFeatures <- tempFeatures[tempFeatures$kernel %in% c(14:17),]
# tempFeatures <- tempRodinia


tempGpuData <- tempFeatures[, names(tempFeatures) %in% c(names(gpus), "device")]
tempFeatures <- tempFeatures[, !names(tempFeatures) %in% c(names(gpus), "device")]

tempKernel <- tempFeatures$name
tempFeatures$kernel <- NULL
tempFeatures$name <- NULL

tempDuration <- tempFeatures$duration

nums <- sapply(tempFeatures, is.numeric)
tempFeatures <- tempFeatures[, nums]

tempFeatures[apply(tempFeatures, 2, is.infinite)] <- 0
tempFeatures[apply(tempFeatures, 2, is.na)] <- 0

tempFeatures <- tempFeatures[, apply(tempFeatures, 2, function(v) var(v, na.rm = TRUE) != 0)]

NumberGPUParameters <- 3

corFeaturesGPU <- abs(cor(normalizeLogMax(getElement(tempFeatures, "duration")), apply(
    tempGpuData[, !names(tempGpuData) %in%c("compute_version", "gpu_id", "device", "gpu_name", "l1_cache_used")], 2, normalizeLogMax),
    method = "spearman", use = "complete.obs"))

GPUParameters <- tempGpuData[names(corFeaturesGPU[, order(corFeaturesGPU, decreasing = TRUE)][1:NumberGPUParameters])]


corFeatures <- cor(normalizeLogMax(getElement(tempFeatures, "duration")), apply(tempFeatures, 2, normalizeLogMax),
                   method = "spearman", use = "complete.obs")

tempFeatures$duration <- NULL
corFeatures <- corFeatures[, colnames(corFeatures) != "duration"]


Result <- data.frame()
# "lm", "step", "glm", "svm", "rf", "em"
for(iML in c("lm")) {
    
    for(threshCorr in c(0.75)){
        tempData <- data.frame()
        tempData <- subset(tempFeatures[which(abs(corFeatures) >= threshCorr)])
        
        # varImp(tempData)
        
        col <- colorRampPalette(c("blue", "yellow", "red"))(20)
        png(filename = paste("./images/context-2/correlation/heatMap_All_App_GPUs ", "-Thresh=", threshCorr, ".png", sep=""), width = 1600, height = 800)
        heatmap(x = cor(apply(tempData, 2, normalizeLogMax),
                        method = "spearman", use = "complete.obs"),
                col = col, symm = TRUE)
        dev.off()
        
        png(filename = paste("./images/context-2/correlation/corClustring_All_App_GPUs", "-Thresh=", threshCorr, ".png", sep=""), width = 1600, height = 800)
        corrplot(cor(apply(tempData, 2, normalizeLogMax),
                     method = "spearman", use = "complete.obs"), type = "upper", order = "hclust", hclust.method="average")
        dev.off()
        
        if(length(tempData) > 10){
            hcFeatures <- hclust(as.dist(1-abs(cor(apply(tempData, 2, normalizeLogMax),
                                                   method = "spearman", use = "complete.obs"))), method = "average")
            
            # plot(hcFeatures)
            
            # roc_imp <- filterVarImp(x = tempData, y = tempDuration)
            
            for(numberFeatures in c(5, 10)){
                
                cutedTree <- cutree(hcFeatures, k = numberFeatures)
                
                png(filename = paste("./images/context-2/cluster/All_App_GPUs",
                                     "-Thresh=", threshCorr, " NParam=", numberFeatures, ".png", sep=""), 
                    width = 1600, height = 800)
                
                dend <- as.dendrogram(hcFeatures)
                dend %>% color_branches(k=numberFeatures) %>% plot(horiz=TRUE, 
                                                                   main = paste( gpus[gpu,'gpu_name'], " Thresh=", 
                                                                                 threshCorr, " NParam=", numberFeatures, sep=""))
                
                # add horiz rect
                dend %>% rect.dendrogram(k=numberFeatures,horiz=TRUE)
                # add horiz (well, vertical) line:
                abline(v = heights_per_k.dendrogram(dend)[paste(numberFeatures, sep = "")], 
                       lwd = 2, lty = 2, col = "blue")
                # text(50, 50, table(cutedTree))
                dev.off()
                
                parNameTemp <- vector()
                
                for(numberCluster in 1:numberFeatures){
                    Tempvariance <-  apply(apply(tempData[cutedTree == numberCluster],2, normalizeLogMax), 2,var)
                    parNameTemp[numberCluster] <- names(sort(Tempvariance)[length(Tempvariance)])
                }
                Data <- tempData[parNameTemp]
                
                Data <- apply(Data, 2, normalizeLogMax)
                
                Data <- data.frame(Data, 
                                   GPUParameters,
                                   duration=normalizeLogMax(tempDuration), 
                                   kernel=tempKernel)
                for(kernelApp in c(14:17)) {
                    trainingSet <- subset(Data,  kernel !=  names(kernelsDict[kernelApp]))  # training data
                    testSet  <- subset(Data, kernel ==  names(kernelsDict[kernelApp]))   # test data
                    
                    dim(Data)
                    dim(trainingSet)
                    dim(testSet)
                    
                    trainingDuration <- as.matrix(trainingSet$duration)
                    trainingSet$duration <- NULL
                    trainingSet$kernel <- NULL
                    
                    testDuration <- as.matrix(testSet$duration)
                    testSet$duration <- NULL
                    testSet$kernel <- NULL
                    
                    # cl <- makeCluster(8)
                    # registerDoParallel(cl)
                    
                    if (iML == "lm") fit <- lm(trainingDuration ~ ., data = trainingSet)
                    
                    if (iML == "rf") fit <- randomForest(trainingDuration ~ ., data = trainingSet, mtry=3, ntree=50)
                    
                    if (iML == "svm") fit <- svm(trainingDuration ~ ., data = trainingSet, kernel="radial", scale=TRUE)
                    
                    # stopCluster(cl)
                    
                   
                    predictions <- predict(fit, testSet)
                    
                    accuracy <- predictions/testDuration
                    mape <- mean(abs(testDuration  - predictions)/abs(testDuration))*(100)
                    
                    tempResult <- data.frame(Kernels=names(kernelsDict[kernelApp]), 
                                             Gpus=testSet$device, 
                                             Measured=testDuration, 
                                             Predicted=predictions, 
                                             Accuracy=accuracy, 
                                             threshCorr=threshCorr, 
                                             numberFeatures=numberFeatures,
                                             mape=mape)
                    
                    Result <- rbind(Result, tempResult)
                }
            }
        }
    }
    Result$threshCorr <- as.character(Result$threshCorr)
    Result$numberFeatures <- as.character(Result$numberFeatures)
    
    colnames(Result) <-c( "CUDAKernels", "GPUs", "measured", "predicted",  "accuracy", "threshCorr", "numberFeatures", "mape")
    Result$threshCorr <- as.character(Result$threshCorr)
    Result$numberFeatures <- as.character(Result$numberFeatures)
    
    Graph <- ggplot(data=Result, aes(x=CUDAKernels, y=accuracy, group=CUDAKernels, col=CUDAKernels)) +
        geom_boxplot(size=1, outlier.size = 1.5) + #scale_y_continuous(limits =  c(0, 2)) +
        stat_boxplot(geom ='errorbar') +
        xlab(" ") + 
        theme_bw() +
        theme(axis.text.x=element_blank()) +
        theme(legend.title = element_blank()) +
        ylab(expression(paste("Accuracy ",T[k]/T[m] ))) +
        facet_wrap(~numberFeatures, scales="fixed") +
      scale_colour_grey()
    
    ggsave(paste("./images/context-2/", iML, ".pdf",sep=""), Graph, height=10, width=20)
    write.csv(Result, file(paste("./results/context-2-", iML, ".csv",sep="")))
}

print(sum(Result$mape[Result$numberFeatures == 5])/length(Result$mape[Result$numberFeatures == 5]))
print(sum(Result$mape[Result$numberFeatures == 10])/length(Result$mape[Result$numberFeatures == 10]))
