library(e1071)
library(ggplot2)
library(plyr)

library("data.table")
library("ff")


dirpath <- "~/Dropbox/Doctorate/Theses/gpuperfpredict/"
setwd(paste(dirpath, sep=""))

source("./R-code/include/common.R")
source("./R-code/include/sharedFunctions.R")

Parameters <- c("device", "name", "kernel", "input.size.1", "input.size.2", "duration", 
                "achieved_occupancy",
                "gld_request", "gst_request", "global_load_transactions_per_request", "global_store_transactions_per_request",
                "shared_load_transactions", "shared_store_transactions",
                "floating_point_operations.single_precision.", "warps_launched", "block.x")

set.seed(5)
NroSamples <- c(57,57, rep(100, 11))

result <- data.frame()
for(kernelApp in c(1:6, 9:13)){
    tempFeatures <- data.frame()
    for(gpu in c(1:9)) {
        # data.frame(cbind(fread(file = paste("./datasets/",names(kernelsDict[kernelApp]), "-", 
        # gpus[gpu,'gpu_name'], ".csv", sep=""),check.names = TRUE), gpus[gpu,]))
        tempAppGpu <- data.frame(cbind(fread(file = paste("./datasets/",names(kernelsDict[kernelApp]), 
                                                          "-", gpus[gpu,'gpu_name'], ".csv", sep=""), check.names = TRUE), kernel = kernelApp))        
        tempAppGpu <- cbind(tempAppGpu, gpus[gpu,], row.names = NULL)
        tempFeatures <- rbind(tempFeatures, tempAppGpu[sample(nrow(tempAppGpu), NroSamples[kernelApp]),])
    }
    
    Data <- rbind(tempFeatures[c(Parameters)])
    Data[rowSums(is.na(Data)) == 0,]
    Data$name <-  NULL
    
    
    Data <- Data[, apply(Data, 2, function(v) var(v, na.rm = TRUE) != 0)]
    
    # if (kernelApp == 2 || kernelApp == 3){
    #     Data$shared_store_transactions <- NULL
    # }
    
    for (gpu in c(1:9)){
        trainingSet <- subset(Data, device != gpu)
        testSet <- subset(Data, device == gpu)
        
        dim(Data)
        dim(trainingSet)
        dim(testSet)
        
        trainingSet$name <- NULL
        trainingSet$device <- NULL
        trainingSet$kernel <- NULL
        
        TestDuration <- as.matrix(testSet$duration)
        CUDAKernels <- names(kernelsDict[kernelApp])
        GPUs <- gpus[gpu, "gpu_name"]
        
        testSet$name <- NULL
        testSet$device <- NULL
        testSet$duration <- NULL
        testSet$AppId <- NULL
        testSet$gpu_id <- NULL
        
        trainingSet <- log(trainingSet + 0.0000000001,2)
        testSet <- log(testSet + 0.0000000001,2)
        
        fit <- svm(trainingSet$duration ~ ., data = trainingSet, kernel="linear", scale=FALSE) 
        
        predictions <- predict(fit, testSet)
        predictions <- as.matrix(2^predictions) - 0.0000000001
    
        
        mape <- mean(abs(predictions - TestDuration)/abs(TestDuration))*100
        acc <- predictions/TestDuration
        
        tempresult <- data.frame(GPUs, CUDAKernels, TestDuration, predictions, acc, mape)
        
        result <- rbind(result, tempresult)
    }
}

result$CUDAKernels <- revalue(result$CUDAKernels, c("bpnn_layerforward_CUDA"="BCK-K1", "bpnn_adjust_weights_cuda"="BCK-K2", 
                                      "Fan1"="GAU-K1", "Fan2"="GAU-K2",
                                      "kernel"="HTW", "calculate_temp"="HOT", 
                                      "lud_diagonal"="LUD-K1", "lud_internal"="LUD-K2", "lud_perimeter"="LUD-K3", 
                                      "needle_cuda_shared_1"="NDL-K1", "needle_cuda_shared_2"="NDL-K2"))

result$GPUs <- factor(result$GPUs, levels = c( "GTX-680", "Tesla-K20", "Tesla-K40",  "Quadro", "Titan", "TitanX", "GTX-970",    "GTX-980",  "Tesla-P100"))

result <- subset(result, GPUs %in% c("Tesla-K20",  "Tesla-K40", "Titan", "GTX-980", "Tesla-P100"))


resultRFRodinia <- result        
Graph <- ggplot(data=result, aes(x=GPUs, y=acc, group=GPUs, col=GPUs)) + 
    geom_boxplot( size=1.5, outlier.size = 2.5) + scale_y_continuous(limits =  c(0, 2)) +
    stat_boxplot(geom ='errorbar') +
    xlab(" ") + 
    theme_bw() +
    ggtitle("Accuracy with Support Vector Machines technique") +
    theme(plot.title = element_text(hjust = 0.5)) +
    ylab(expression(paste("Accuracy ",T[k]/T[m] ))) +
    theme(plot.title = element_text(family = "Times", face="bold", size=40)) +
    theme(axis.title = element_text(family = "Times", face="bold", size=30)) +
    theme(axis.text  = element_text(family = "Times", face="bold", size=20, colour = "Black")) +
    theme(axis.text.x=element_blank()) +
    theme(legend.title  = element_text(family = "Times", face="bold", size=0)) +
    theme(legend.text  = element_text(family = "Times", face="bold", size=20)) +
    theme(legend.direction = "horizontal", 
          legend.position = "bottom",
          legend.key=element_rect(size=5),
          legend.key.size = unit(5, "lines")) +
    # facet_grid(.~Apps, scales="fixed") 
    facet_wrap(~CUDAKernels, ncol=3, scales="free") +
    theme(strip.text = element_text(size=20)) +
    scale_colour_grey()

ggsave(paste("./images/SVM-Rodinia-fair.pdf",sep=""), Graph, device = pdf, height=10, width=16)
write.csv(result, file = "./results/SVM-Rodinia-fair.csv")

