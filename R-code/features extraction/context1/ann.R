library("nnet")
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

library("pls")

dirpath <- "~/Dropbox/Doctorate/GIT/BSyncGPGPU/"
setwd(paste(dirpath, sep=""))

source("./R-code/common.R")
set.seed(5)
NroSamples <- c(57,57, rep(100, 11))
for(gpu in c(1, 2, 6, 7, 9, 10)) {
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
    for(iML in c("ann")){
        for(threshCorr in c(0.5, 0.75)){
            tempDataset <- data.frame()
            tempDataset <- tempFeatures[which(abs(corFeatures) >= threshCorr)]
            
            if(length(tempDataset) > 10){
                hcFeatures <- hclust(as.dist(cor(tempDataset, 
                                                 method = "spearman", use = "all.obs"), 
                                             upper = FALSE), method = "average")
                
                for(numberFeatures in c(10, 5)){
                    cutedTree <- cutree(hcFeatures, k=numberFeatures)
                    # table(cutedTree)
                    
                    parNameTemp <- vector()
                    for(numberCluster in 1:numberFeatures){
                        Tempvariance <- sapply(tempData[cutedTree == numberCluster], var)
                        parNameTemp[numberCluster] <- names(tempData[names(Tempvariance == max(Tempvariance))])
                    }
                    
                    Data <- tempDataset[parNameTemp]
                    Data <- cbind(Data, duration=tempDuration, kernel=tempKernel)
                    
                    for(kernelApp in c(1:7, 9:13)) {
                        
                        trainingData <- subset(Data,  kernel !=  kernelApp)   # training data
                        testData  <- subset(Data, kernel ==  kernelApp)   # test data
                        
                        trainingDuration <- trainingData$duration
                        trainingData$duration <- NULL
                        trainingData$kernel <- NULL
                        
                        testDuration <- testData$duration
                        testData$duration <- NULL
                        testData$kernel <- NULL
                        
                        if (iML == "lm") fit <- lm(trainingDuration ~ ., data = trainingData )
                        
                        if (iML == "glm") fit <- glm(trainingDuration ~ ., data = trainingData )
                        
                        if (iML == "rlm") fit <- rlm(trainingDuration ~ ., data = trainingData )
                        
                        if (iML == "ann") fit <- nnet(trainingDuration ~ ., data = trainingData, size =5)
                        
                        if (iML == "svm") fit <- svm(trainingDuration ~ ., data = trainingData, kernel="linear", scale=FALSE )
                        
                        if (iML == "rf") fit <- randomForest(trainingDuration ~ ., data = trainingData, mtry=5,ntree=50)
                        
                        predictions <- predict(fit, testData)
                        
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
            geom_boxplot(size=1, outlier.size = 2.5) + scale_y_continuous(limits =  c(0, 2.5)) +
            stat_boxplot(geom ='errorbar') +
            xlab(" ") + 
            theme_bw() +        
            ylab(expression(paste("Accuracy ",T[k]/T[m] ))) +
            facet_grid(numberFeatures~threshCorr, scales="fixed") 
        ggsave(paste("./images/phase2/", iML, "/",gpus[gpu,'gpu_name'], ".png",sep=""), Graph, height=10, width=20)
    }
}

