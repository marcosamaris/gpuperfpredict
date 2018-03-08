library("robust")
library("robustbase")
library("MASS")
library("randomForest")
library("caret")
library("e1071")
library("ggplot2")
library("data.table")
library("ff")
library("nnet")
library("doParallel")
library("corrplot")
library("magrittr")
library("cluster")
library("dendextend")
library("Hmisc")
library("car")

dirpath <- "~/Dropbox/Doctorate/GIT/BSyncGPGPU/"
setwd(paste(dirpath, sep=""))

source("./code/include/common.R")
source("./code/include/sharedFunctions.R")

set.seed(5)

NroSamples <- c(57,57, rep(100, 11))
tempFeatures <- data.frame()
for(gpu in c(1:9)) {
  for(kernelApp in c(1:7, 9:11)){
    # data.frame(cbind(fread(file = paste("./datasets/",names(kernelsDict[kernelApp]), "-", gpus[gpu,'gpu_name'], ".csv", sep=""),check.names = TRUE), gpus[gpu,]))
    tempAppGpu <- data.frame(cbind(fread(file = paste("./datasets/",names(kernelsDict[kernelApp]), "-", 
                                                      gpus[gpu,'gpu_name'], ".csv", sep=""),check.names = TRUE),gpus[gpu,] ))        
    tempFeatures <- rbind(tempFeatures, tempAppGpu[sample(nrow(tempAppGpu), NroSamples[kernelApp]),])
  }
}
tempFeatures$gst_request <- NULL
tempFeatures$gld_request <- NULL

tempFeatures$X <- NULL
tempFeatures$X.1 <- NULL

tempGpuData <- tempFeatures[, names(tempFeatures) %in% c(names(gpus), "device")]
tempFeatures <- tempFeatures[, !names(tempFeatures) %in% c(names(gpus), "device")]

tempKernel <- tempFeatures$kernel
tempFeatures$kernel <- NULL
tempFeatures$name <- NULL

tempDuration <- tempFeatures$duration

nums <- sapply(tempFeatures, is.numeric)
tempFeatures <- tempFeatures[, nums]

tempFeatures[apply(tempFeatures, 2, is.infinite)] <- 0
tempFeatures[apply(tempFeatures, 2, is.na)] <- 0

tempFeatures <- tempFeatures[, apply(tempFeatures, 2, function(v) var(v, na.rm = TRUE) != 0)]

NumberGPUParameters <- 2

corFeaturesGPU <- abs(cor(normalizeLogMax(getElement(tempFeatures, "duration")), apply(tempGpuData[, !names(tempGpuData) %in%
                                                                                                     c("compute_version", "gpu_id", "gpu_name", "l1_cache_used")], 2, normalizeLogMax),
                          method = "spearman", use = "complete.obs"))

GPUParameters <- tempGpuData[names(corFeaturesGPU[, order(corFeaturesGPU, decreasing = TRUE)][1:NumberGPUParameters])]


corFeatures <- cor(normalizeLogMax(getElement(tempFeatures, "duration")), apply(tempFeatures, 2, normalizeLogMax),
                   method = "spearman", use = "complete.obs")

tempFeatures$duration <- NULL
corFeatures <- corFeatures[, colnames(corFeatures) != "duration"]


Result <- data.frame()
# "lm", "step", "glm", "svm", "rf", "em"
for(iML in c("lm")){
  
  for(threshCorr in c(0.75)){
    tempData <- data.frame()
    tempData <- subset(tempFeatures[which(abs(corFeatures) >= threshCorr)])
    
    # varImp(tempData)
    
    col <- colorRampPalette(c("blue", "yellow", "red"))(20)
    png(filename = paste("./images/phase2/correlation/heatMap_All_App_GPUs ", "-Thresh=", threshCorr, ".png", sep=""), width = 1600, height = 800)
    heatmap(x = cor(apply(tempData, 2, normalizeLogMax),
                    method = "spearman", use = "complete.obs"),
            col = col, symm = TRUE)
    dev.off()
    
    png(filename = paste("./images/phase2/correlation/corClustring_All_App_GPUs", "-Thresh=", threshCorr, ".png", sep=""), width = 1600, height = 800)
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
        
        png(filename = paste("./images/phase2/cluster/All_App_GPUs",
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
                           kernel=tempKernel,
                           gpu_id=tempGpuData$device)
        
        
        # png(filename = paste("./images/phase2/scatterPlot/All_App_GPUs", "-Thresh=", threshCorr, "-NParam=", numberFeatures, ".png", sep=""), width = 1600, height = 800)
        # scatterplotMatrix(Data,cex.labels =  1.5)
        # dev.off()
        

        # png(filename = paste("./images/phase2/fitModels/", iML, "_All_App_GPUs", "-Thresh=", threshCorr, "-NParam=", numberFeatures, ".png", sep=""), width = 1600, height = 800)
        # par(family = "Times", mfrow=c(3,4), mai = c(1, 1, 0.5, 0.5))
        for(gpu in c(1:9)) {
          trainingData <- subset(Data,  gpu_id !=  gpu)  # training data
          testData  <- subset(Data, gpu_id ==  gpu)   # test data
          
          trainingDuration <- trainingData$duration
          trainingData$duration <- NULL
          trainingData$gpu_id <- NULL
          
          testDuration <- testData$duration
          testData$duration <- NULL
          trainingData$gpu_id <- NULL
          
          # cl <- makeCluster(8)
          # registerDoParallel(cl)
          
          if (iML == "lm") fit <- lm(trainingDuration ~ ., data = trainingData)
          
          if (iML == "step") fit <- step(steps = 100, scale = TRUE, direction = "both", trace = FALSE,
                                         lm(trainingDuration ~ ., data = trainingData))
          
          if (iML == "glm") fit <- glm(trainingDuration ~ ., data = trainingData )
          
          if (iML == "svm") fit <- svm(trainingDuration ~ ., data = trainingData, kernel="radial", scale=TRUE)
          
          if (iML == "rf") fit <- randomForest(trainingDuration ~ ., data = trainingData, mtry=3, ntree=20)
          # stopCluster(cl)
          
          if (iML == "em") {
            fit_lm <- lm(trainingDuration ~ ., data = trainingData)
            fit_step <- step(steps = 100, scale = TRUE, direction = "both", trace = FALSE,
                             lm(trainingDuration ~ ., data = trainingData))
            fit_glm <- glm(trainingDuration ~ ., data = trainingData )
            fit_svm <- svm(trainingDuration ~ ., data = trainingData, kernel="linear", scale=TRUE)
            fit_rf <- randomForest(trainingDuration ~ ., data = trainingData, mtry=5,ntree=50)
            
            predictions_lm <- predict(fit_lm, testData)
            predictions_step <- predict(fit_step, testData)
            predictions_glm <- predict(fit_glm, testData)
            predictions_svm <- predict(fit_svm, testData)
            predictions_rf <- predict(fit_rf, testData)
            
            predictions <- rowMedians(as.matrix(cbind(predictions_lm, predictions_step, predictions_glm, predictions_svm, predictions_rf))) 
            
          } else{
            predictions <- predict(fit, testData)
          }
          
          
          # predictions <- predict(fit, testData)
          
          
          # base <- residuals(fit)
          # qqnorm(base, ylab="Studentized Residual",
          #        xlab="t Quantiles",
          #        main=paste(names(kernelsDict[kernelApp]), " Thresh= ", threshCorr, " NParam= ", numberFeatures, sep=""), cex.lab = 2, cex.main=2,cex=1.5,cex.axis=2)
          # qqline(base, col = 2,lwd=5)
          
          
          accuracy <- predictions/testDuration
          maxAccuracy <- max(accuracy)
          minAccuracy <- min(accuracy)
          sdAccuracy <- sd(accuracy)
          
          mse <- mean((predictions - testDuration)^2)
          mae <- mean(abs(predictions - testDuration))
          mape <- mean(abs(predictions - testDuration)/abs(testDuration))*100
          rmse <- sqrt(mean((predictions - testDuration)^2))
          
          tempResult <- data.frame(kernels=testData$kernel,
                                   Gpus=as.character(gpus[gpu,'gpu_name']), 
                                   Measured=testDuration, 
                                   Predicted=predictions, 
                                   Accuracy=accuracy, 
                                   threshCorr=threshCorr, 
                                   numberFeatures=numberFeatures,
                                   mse=mse,
                                   mae=mae,
                                   mape=mape,
                                   rmse=rmse)
          
          Result <- rbind(Result, tempResult)
        }
        # dev.off()
        
        
        # png(filename = paste("./images/phase2/features/All_App_GPUs", "-Thresh_", threshCorr, "-NoFeatures_",numberFeatures, ".png", sep=""), width = 1200, height = 2800)
        # par(mfrow=c(numberFeatures,3))
        # cex.Size <- 2
        # for(featureSelected in 1:(numberFeatures)){
        #   
        #   tempFeature <- Data[,featureSelected]
        #   plot(Data$kernel, tempFeature, xlab="GPUs", cex.lab=cex.Size, cex.axis=cex.Size, ylab=" ")
        #   boxplot(tempFeature~Data$kernel, xlab="GPUs", main=paste(names(Data[featureSelected]), sep=""), 
        #           cex.lab=cex.Size, cex.axis=cex.Size, cex.main=cex.Size)
        #   # hist(Data[,i], main = "", xlab=names(Data[i]), cex.lab=cex.Size, cex.axis=cex.Size)
        #   
        #   # names(tempFeatures[i] "FAN2"
        #   dens <- apply(as.data.frame(matrix(tempFeature, ncol = 8, 
        #                                      nrow = 100)), 2, density)
        #   plot(NA, xlim=range(sapply(dens, "[", "x")), ylim=range(sapply(dens, "[", "y")),
        #        cex.lab=cex.Size, cex.axis=cex.Size)
        #   mapply(lines, dens, col=c(cbbPalette, col[c(1,5,13, 19)]) , lwd=5)
        #   legend("topright", legend=c(1:7, 9:13), fill=1:length(dens), cex = 1.5)
        #   
        # }
        # dev.off()
        # 
        
          write.csv(names(Data), file(paste("./results/phase2/", iML, "_All_App_GPUs", "-NoFeatures_",numberFeatures,".csv",sep="")))
        
      }
    }
  }
  Result$threshCorr <- as.character(Result$threshCorr)
  Result$numberFeatures <- as.character(Result$numberFeatures)
  
  colnames(Result) <-c("kernels", "GPUs", "Measured", "Predicted",  "Accuracy", "threshCorr", "numberFeatures", "mse", "mae", "mape", "rmse")
  Result$threshCorr <- as.character(Result$threshCorr)
  Result$numberFeatures <- as.character(Result$numberFeatures)
  
  Graph <- ggplot(data=Result, aes(x=GPUs, y=Accuracy, group=GPUs, col=GPUs)) +
    geom_boxplot(size=1, outlier.size = 1.5) + #scale_y_continuous(limits =  c(0.5, 2)) +
    stat_boxplot(geom ='errorbar') +
    xlab(" ") + 
    theme_bw() +
    theme(axis.text.x=element_blank()) +
    theme(legend.title = element_blank()) +
    scale_colour_manual(values=c(cbbPalette, col[c(1,5,13, 19)])) +
    ylab(expression(paste("Accuracy ",T[k]/T[m] ))) +
    facet_wrap(~numberFeatures, scales="fixed") 
  ggsave(paste("./images/phase2/", iML, "_All_App_GPUs.pdf",sep=""), Graph, height=10, width=20, units="cm")
  write.csv(Result, file(paste("./results/phase2/", iML, "-All-App-GPUs.csv",sep="")))
}

print(sum(Result$mape[Result$numberFeatures == 5])/length(Result$mape[Result$numberFeatures == 5]))
print(sum(Result$mape[Result$numberFeatures == 10])/length(Result$mape[Result$numberFeatures == 10]))

