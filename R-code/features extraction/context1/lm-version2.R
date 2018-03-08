library("robust")
library("robustbase")
library("MASS")
library("randomForest")
library("caret")
library("e1071")
library("ggplot2")
library("data.table")
library("ff")
library("doParallel")

dirpath <- "~/Dropbox/Doctorate/GIT/BSyncGPGPU/"
setwd(paste(dirpath, sep = ""))

source("./R-code/common.R")
NroSamples <- c(57, 57, rep(100, 11))
for(gpu in c(1, 2, 6, 7, 9)) {
    tempFeatures <- data.frame()
    
    for(kernelApp in c(1:7, 9:13)){
        tempAppGpu <- data.frame(cbind(fread(file = paste("./datasets/", 
                                                          names(kernelsDict[kernelApp]), "-", 
                                                          gpus[gpu, 'gpu_name'], ".csv", sep = ""), 
                                             check.names = TRUE, stringsAsFactors = FALSE),
                                       gpus[gpu, ]))
        tempFeatures <- rbind(tempFeatures, 
                              tempAppGpu[sample(nrow(tempAppGpu), 
                                                NroSamples[kernelApp]), ])
    }
    tempFeatures <- tempFeatures[names(tempFeatures) != "V1"]
    
    tempKernel <- tempFeatures$kernel
    tempGpuData <-
        tempFeatures[, names(tempFeatures) %in% c(names(gpus))]
    tempFeatures <-
        tempFeatures[, !names(tempFeatures) %in% c(names(gpus))]
    
    nums <- sapply(tempFeatures, is.numeric)
    tempFeatures <- tempFeatures[, nums]
    
    tempFeatures[apply(tempFeatures, 2, is.infinite)] <- 0
    tempFeatures[apply(tempFeatures, 2, is.na)] <- 0
    
    tempDevice <- tempFeatures$device
    tempFeatures$device <- NULL
    tempDuration <- tempFeatures$duration
    
    tempFeatures <-
        tempFeatures[, apply(tempFeatures, 2, function(v)
            var(v, na.rm = TRUE) != 0)]
    
    corFeatures <- cor(getElement(tempFeatures, "duration"), tempFeatures, method = "spearman", use = "all.obs")
    
    # "lm" , "glm", "svm", "rf"
    for(iML in c("em")){
        Result <- data.frame()
        Result <- data.frame()
        for (threshCorr in c(0.50, 0.75)) {
            Data <- data.frame(log(subset(tempFeatures[which(abs(corFeatures) >= threshCorr)]) +  0.000000000000001))
            Data <- cbind(Data, gpu_id=tempGpuData$gpu_id, bw=log(tempGpuData$bandwith), tFlops=log(tempGpuData$num_of_cores), kernel=tempKernel)
            Data$compute_version <- NULL
            Data$gpu_name <- NULL
            if(length(Data) >= 5){
                for(kernelApp in c(1:7, 9:13)) {
                    
                    trainingData <- subset(Data, kernel  != kernelApp )  # training data
                    testData  <- subset(Data, kernel ==  kernelApp)   # test data
                    
                    trainingDuration <- trainingData$duration
                    trainingData$duration <- NULL
                    trainingData$kernel <- NULL
                    
                    
                    testDuration <- testData$duration
                    testData$duration <- NULL
                    trainingData$kernel <- NULL
                    
                    # cl <- makeCluster(8)
                    # registerDoParallel(cl)
                    
                    if (iML == "em") {
                        fit.lm <- lm(trainingDuration ~ ., data = trainingData)
                        fit.svm <- svm(trainingDuration ~ ., data = trainingData, kernel="linear", scale=TRUE)
                        fit.rf <- randomForest(trainingDuration ~ ., data = trainingData, mtry=5,ntree=50)
                    }
                    predictions.lm <- predict(fit.lm, testData)
                    predictions.svm <- predict(fit.svm, testData)
                    predictions.rf <- predict(fit.rf, testData)
                    
                    predictions <- rowMedians(as.matrix(cbind(predictions.lm, predictions.svm,predictions.rf))) 
                    
                    # print(coefficients(fit)) # model coefficients
                    # print(confint(fit, level = 0.5)) # CIs for model parameters
                    # print(fitted(fit)) # predicted values
                    # print(residuals(fit)) # residuals
                    # print(anova(fit)) # anova table
                    # print(vcov(fit)) # covariance matrix for model parameters
                    # print(influence(fit)) # regression diagnostics
                    
                    predictions <- 2 ^ predictions - 0.000000000000001
                    testDuration <- 2 ^ testDuration - 0.000000000000001
                    accuracy <- predictions / testDuration
                    
                    maxAccuracy <- max(accuracy)
                    minAccuracy <- min(accuracy)
                    sdAccuracy <- sd(accuracy)
                    
                    tempResult <-
                        data.frame(
                            Gpus=gpus[gpu, 'gpu_name'],
                            Kernels=names(kernelsDict[kernelApp]),
                            Measured=testDuration,
                            Predicted=predictions,
                            Accuracy=accuracy,
                            threshCorr=threshCorr,
                            maxAccuracy,
                            minAccuracy,
                            sdAccuracy
                        )
                    
                    Result <- rbind(Result, tempResult)
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
            theme(axis.text.x=element_blank()) +
            ylab(expression(paste("Accuracy ",T[k]/T[m] ))) +
            facet_wrap(~threshCorr, scales="free") 
        ggsave(paste("./images/phase2/", iML, "/",gpus[gpu,'gpu_name'], ".png",sep=""), Graph, height=10, width=20)
    }
}

