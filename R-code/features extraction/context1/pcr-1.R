library("pls")
library("MASS")
library("randomForest")
library("caret")
library("e1071")
library("ggplot2")
library("data.table")
library("ff")
library("doParallel")
library("pls")

dirpath <- "~/Dropbox/Doctorate/GIT/BSyncGPGPU/"
setwd(paste(dirpath, sep=""))

source("./R-code/common.R")
set.seed(5)

for(kernelApp in c(1:7, 9:13)) {
    tempFeatures <- data.frame()
    for(gpu in c(1, 2, 3, 6, 7, 9)){
        tempAppGpu <- data.frame(cbind(fread(file = paste("./datasets/",names(kernelsDict[kernelApp]), "-", gpus[gpu,'gpu_name'], ".csv", sep=""),check.names = TRUE), gpus[gpu,]))
        tempFeatures <- rbind(tempFeatures, tempAppGpu[sample(nrow(tempAppGpu), 46),])
        
    }
    
    tempFeatures <- tempFeatures[names(tempFeatures) != "V1"]
    
    tempGpuData <- tempFeatures[, names(tempFeatures) %in% c(names(gpus))]
    tempFeatures <- tempFeatures[,!names(tempFeatures) %in% c(names(gpus))]
    
    nums <- sapply(tempFeatures, is.numeric)
    tempFeatures <- tempFeatures[,nums]
    
    tempFeatures[apply(tempFeatures, 2, is.infinite)] <- 0
    tempFeatures[apply(tempFeatures, 2, is.na)] <- 0
    
    tempDevice <- tempFeatures$device
    tempFeatures$device <- NULL
    tempDuration <- tempFeatures$duration
    
    tempFeatures <- tempFeatures[,apply(tempFeatures, 2, function(v) var(v, na.rm=TRUE)!=0)]
    
    
    # corFeatures <- apply()
    corFeatures <- cor(getElement(tempFeatures, "duration"), tempFeatures, method = "spearman", use = "pairwise.complete.obs")
    
    tempFeatures$duration <- NULL
    corFeatures <- corFeatures[, colnames(corFeatures) != "duration"]
    
    Result <- data.frame()
    
    # , "glm", "svm", "rf"
    for(iML in c("pcr")){
        for(threshCorr in c(0, 0.25, 0.5)){
            tempDataset <- data.frame()
            tempDataset <- tempFeatures[which(abs(corFeatures) >= threshCorr)]
            
            #   PCR - http://www.milanor.net/blog/performing-principal-components-regression-pcr-in-r/
            
            Data <- cbind(tempDataset, duration=tempDuration, gpu_id=tempGpuData$gpu_id, num_of_cores=tempGpuData$num_sp_per_sm, num_of_sm=tempGpuData$num_of_sm)
            
            if(length(tempDataset) > 20){
                for(numberFeatures in c(30, 20, 10, 5, 1)){
                    for(gpu in c(1, 2, 3, 6, 7, 9)) {
                        
                        trainingData <- log(subset(Data, gpu_id !=  gpu) + 0.000000000000001)  # training data
                        testData  <- log(subset(Data, gpu_id ==  gpu) + 0.000000000000001)   # test data
                        
                        trainingDuration <- trainingData$duration
                        trainingData$duration <- NULL
                        trainingData$gpu_id <- NULL
                        
                        testDuration <- testData$duration
                        testData$duration <- NULL
                        testData$gpu_id <- NULL
                        
                        if (iML == "pcr") fit <- pcr(trainingDuration ~ ., data = trainingData, scale=TRUE, validation = "CV")
                        
                        # validationplot(fit, val.type="R2")
                        # predplot(fit)
                        # coefplot(fit)
                        
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
        
        if (iML == "lm") ML= "LM"
        
        if (iML == "glm") ML= "GLM"
        
        if (iML == "rlm") ML= "RLM"
        
        if (iML == "svm") ML= "SVM"
        
        if (iML == "rf") ML= "RF"
        
        if (iML == "pcr") ML= "PCR"
        
        colnames(Result) <-c("Gpus", "Kernels", "Measured", "Predicted",  "Accuracy", "threshCorr", "numberFeatures")
        Result$threshCorr <- as.character(Result$threshCorr)
        Result$numberFeatures <- as.character(Result$numberFeatures)
        
        Graph <- ggplot(data=Result, aes(x=Gpus, y=Accuracy, group=Gpus, col=Gpus)) +
            geom_boxplot(size=1, outlier.size = 2.5) + scale_y_continuous(limits =  c(0, 2.5)) +
            stat_boxplot(geom ='errorbar') +
            xlab(" ") + 
            theme_bw() +        
            ylab(expression(paste("Accuracy ",T[k]/T[m] ))) +
            facet_grid(numberFeatures~threshCorr, scales="fixed") 
        ggsave(paste("./images/phase1/", ML, "/",names(kernelsDict[kernelApp]), ".png",sep=""), Graph, height=10, width=20)
    }
}

