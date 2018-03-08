library("pls")
library("MASS")
library("randomForest")
library("caret")
library("e1071")
library("ggplot2")
library("data.table")
library("ff")
library("doParallel")


dirpath <- "~/Dropbox/Doctorate/GIT/BSyncGPGPU/"
setwd(paste(dirpath, sep=""))

source("./R-code/common.R")
set.seed(5)
NroSamples <- c(57,57, rep(100, 11))
for(gpu in c(1, 2, 6, 7, 9)) {
    tempFeatures <- data.frame()
    for(kernelApp in c(1:7, 9:13)){
        # data.frame(cbind(fread(file = paste("./datasets/",names(kernelsDict[kernelApp]), "-", gpus[gpu,'gpu_name'], ".csv", sep=""),check.names = TRUE), gpus[gpu,]))
        tempAppGpu <- data.frame(cbind(fread(file = paste("./datasets/",names(kernelsDict[kernelApp]), "-", gpus[gpu,'gpu_name'], ".csv", sep=""),check.names = TRUE), kernel = kernelApp))        
        tempFeatures <- rbind(tempFeatures, tempAppGpu[sample(nrow(tempAppGpu), NroSamples[kernelApp]),])
    }
    tempFeatures <-tempFeatures[names(tempFeatures) != "X"]
    tempKernel <- tempFeatures$kernel
    
    nums <- sapply(tempFeatures, is.numeric)
    tempFeatures <- tempFeatures[,nums]
    
    tempFeatures[apply(tempFeatures, 2, is.infinite)] <- 0
    tempFeatures[apply(tempFeatures, 2, is.na)] <- 0
    
    # tempDevice <- tempFeatures
    # tempFeatures$device <- NULL
    tempDuration <- tempFeatures$duration
    
    tempFeatures <- tempFeatures[,apply(tempFeatures, 2, function(v) var(v, na.rm=TRUE)!=0)]
    
    corFeatures <- cor(getElement(tempFeatures, "duration"), tempFeatures, method = "spearman", use = "complete.obs")
    
    tempFeatures$duration <- NULL
    corFeatures <- corFeatures[, colnames(corFeatures) != "duration"]
    
    Result <- data.frame()
    
    # "lm" , "glm", "svm", "rf"
    for(iML in c("pcr")){
        for(threshCorr in c(0.5, 0.75)){
            tempDataset <- data.frame()
            tempDataset <- tempFeatures[which(abs(corFeatures) >= threshCorr)]
            Data <- cbind(tempDataset, duration=tempDuration, kernel=tempKernel)
            
            if(length(Data) > 10){
                for(numberFeatures in c(9, 5, 3, 1)){
                    for(kernelApp in c(1:7, 9:13)) {
                        
                        trainingData <- log(subset(Data, kernel !=  kernelApp) + 0.000000000000001)  # training data
                        testData  <- log(subset(Data, kernel ==  kernelApp) + 0.000000000000001)   # test data
                        
                        trainingDuration <- trainingData$duration
                        trainingData$duration <- NULL
                        trainingData$kernel <- NULL
                        
                        testDuration <- testData$duration
                        testData$duration <- NULL
                        testData$kernel <- NULL
                        
                        if (iML == "pcr") fit <- pcr(trainingDuration ~ ., data = trainingData, scale=TRUE, validation = "CV")
                        
                        predictions <- predict(fit, testData, comps=numberFeatures)

                        predictions <- 2^predictions - 0.000000000000001
                        testDuration <- 2^testDuration - 0.000000000000001
                        accuracy <- predictions/testDuration
                        
                        tempResult <- data.frame(gpus[gpu,'gpu_name'], names(kernelsDict[kernelApp]), testDuration, predictions, accuracy, threshCorr, numberFeatures)
                        
                        Result <- rbind(Result, tempResult)
                        
                    }
                }
            }
        }
        
        colnames(Result) <-c("Gpus", "Kernels", "Measured", "Predicted",  "Accuracy", "threshCorr", "numberFeatures")
        Result$threshCorr <- as.character(Result$threshCorr)
        Result$numberFeatures <- as.character(Result$numberFeatures)
        
        Graph <- ggplot(data=Result, aes(x=Kernels, y=Accuracy, group=Kernels, col=Kernels)) +
            geom_boxplot(size=1, outlier.size = 2.5) +
            stat_boxplot(geom ='errorbar') +
            xlab(" ") + 
            theme_bw() +        
            ylab(expression(paste("Accuracy ",T[k]/T[m] ))) +
            facet_wrap(numberFeatures~threshCorr, scales="free", ncol = 2) 
        ggsave(paste("./images/phase2/", iML, "/",gpus[gpu,'gpu_name'], ".png",sep=""), Graph, height=10, width=20)
    }
}

