library("MASS")
library("randomForest")
library("caret")
library("e1071")
library("ggplot2")
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
NroSamples <- c(57,57, rep(1000, 11))

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

    tempFeatures <- rbind(tempFeatures[c(Parameters)])
    
    Data <- subset(tempFeatures, kernel == kernelApp)
    # Data[rowSums(is.na(Data)) == 0,]
    
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
            testSet$kernel <- NULL
            testSet$duration <- NULL
            
            trainingSet <- log(trainingSet + 0.0000000001, 2)
            testSet <- log(testSet + 0.0000000001, 2)
            
            base <- lm(trainingSet$duration ~ ., data = trainingSet) 
            
            predictions <- predict(base, testSet)
            predictions <- as.matrix(2^predictions) -  0.0000000001
            
            acc <- predictions/TestDuration
            mape <- mean(abs(TestDuration  - predictions)/abs(predictions))*(100)
            
            tempresult <- data.frame(GPUs, CUDAKernels, TestDuration, predictions, acc,mape)
            
            result <- rbind(result, tempresult)
        }
    }
        
        
result$CUDAKernels <- revalue(result$CUDAKernels, c("bpnn_layerforward_CUDA"="BCK-K1", "bpnn_adjust_weights_cuda"="BCK-K2", 
                                                  "Fan1"="GAU-K1", "Fan2"="GAU-K2",
                                                  "calculate_temp"="HOT", "kernel"="HTW",
                                                  "lud_diagonal"="LUD-K1", "lud_internal"="LUD-K2", "lud_perimeter"="LUD-K3", 
                                                  "needle_cuda_shared_1"="NDL-K1", "needle_cuda_shared_2"="NDL-K2"))
    
result$GPUs <- factor(result$GPUs, levels = c( "GTX-680", "Tesla-K20", "Tesla-K40",  "Quadro", "Titan", "TitanX", "GTX-970",    "GTX-980",  "Tesla-P100"))
    
result <- subset(result, GPUs %in% c("Tesla-K20",  "Tesla-K40", "Titan", "GTX-980", "Tesla-P100"))
    
resultLMRodinia <- result        
Graph <- ggplot(data=result, aes(x=GPUs, y=acc, group=GPUs, col=GPUs)) + 
    geom_boxplot( size=1.5, outlier.size = 2.5) + scale_y_continuous(limits =  c(0, 2)) +
    stat_boxplot(geom ='errorbar') +
    xlab(" ") + 
    theme_bw() +
    ggtitle("Accuracy with Linear Regression technique") +
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
        
    ggsave(paste("./images/LinearRegression-Rodinia-fair.pdf",sep=""), Graph, device = pdf, height=10, width=16)
    write.csv(result, file = "./results/LinearRegression-Rodinia-fair.csv")
        
    
