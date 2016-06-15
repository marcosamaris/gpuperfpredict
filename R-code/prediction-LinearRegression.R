library(e1071)
library(ggplot2)

dirpath <- "~/Doctorate/svm-gpuperf/"
setwd(paste(dirpath, sep=""))

gpus <- read.table("./R-code/deviceInfo.csv", sep=",", header=T)
NoGPU <- dim(gpus)[1]

apps <- c("matMul_gpu_uncoalesced","matMul_gpu", "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem",
          "matrix_sum_normal", "matrix_sum_coalesced", 
          "dotProd", "vectorAdd",  "subSeqMax")

Parameters <- c("gpu_name","gpu_id", "AppName", "AppId", "Input.Size", "Duration", 
                   "max_clock_rate",	"num_of_cores",	
                   "Achieved.Occupancy",
                    "totalLoadGM", "totalStoreGM", "totalLoadSM", "totalStoreSM",
                   "inst_issued2",
                   "blockSize", "GridSize"
)

DataAppGPU <- read.csv(file = paste("./R-code/Datasets/CleanData/App-GPU-CC-All.csv", sep = ""))

DataAppGPU <- rbind(DataAppGPU[c(Parameters)])

result <- data.frame()
for (CC in c(1:10)){
    for( j in 1:9) {
        Data <- subset(DataAppGPU, AppId == j )
        dim(Data)
        
        # Data <- Data[complete.cases(Data),]
        
        # if (CC <= 6 ){
        #     Data[["gld_request"]] <- scale(Data[["gld_request"]], center = FALSE, scale = max(Data["gld_request"], na.rm = TRUE)/100)
        #     Data[["gst_request"]] <- scale(Data[["gst_request"]], center = FALSE, scale = max(Data["gst_request"], na.rm = TRUE)/100)
        # } else {
        #     Data[["global_load"]] <- scale(Data[["global_load"]], center = FALSE, scale = max(Data["global_load"], na.rm = TRUE)/100)
        #     Data[["global_store"]] <- scale(Data[["global_store"]], center = FALSE, scale = max(Data["global_store"], na.rm = TRUE)/100)
        # }
        # 
        # if(CC <=7 ){
        #     Data[["Floating.Point.Operations.Single.Precision."]] <- scale(Data[["Floating.Point.Operations.Single.Precision."]], center = FALSE, scale = max(Data["Floating.Point.Operations.Single.Precision."], na.rm = TRUE)/100)
        # } else {
        #     Data[["FP.Instructions.Single."]] <- scale(Data[["FP.Instructions.Single."]], center = FALSE, scale = max(Data["FP.Instructions.Single."], na.rm = TRUE)/100)
        # }
        # 
        # 
        # if (j == 4 | j == 3 | j == 9){
        #     Data[["shared_load"]] <- scale(Data[["shared_load"]], center = FALSE, scale = max(Data["shared_load"], na.rm = TRUE)/100)
        #     Data[["shared_store"]] <- scale(Data[["shared_store"]], center = FALSE, scale = max(Data["shared_store"], na.rm = TRUE)/100)
        # }
        # Data[["inst_issued2"]] <- scale(Data[["inst_issued2"]], center = FALSE, scale = max(Data["inst_issued2"], na.rm = TRUE)/100)
        # Data[["warps_launched"]] <- scale(Data[["warps_launched"]], center = FALSE, scale = max(Data["warps_launched"], na.rm = TRUE)/100)
        
        
        if(j != 3 | j != 4){
            Data$totalLoadSM <- NULL
            Data$totalStoreSM <- NULL
        }
        
        trainingSet <- subset(Data, gpu_id != CC)
        testSet <- subset(Data, gpu_id == CC)
        dim(trainingSet)
        dim(testSet)
        
        trainingSet$AppName <- NULL
        trainingSet$gpu_name <- NULL
        trainingSet$AppId <- NULL
        trainingSet$gpu_id <- NULL
        # trainingDuration <- trainingSet["Duration"]
        # trainingSet$Duration <- NULL
        dim(trainingSet)
        
        TestDuration <- testSet["Duration"]
        Size <- testSet["Input.Size"]
        App <- testSet["AppName"]
        Gpu <- testSet["gpu_name"]
        Block <- testSet["blockSize"]
        
        testSet$AppName <- NULL
        testSet$gpu_name <- NULL
        testSet$Duration <- NULL
        testSet$AppId <- NULL
        testSet$gpu_id <- NULL
        dim(testSet)
        
        base <- lm(trainingSet$Duration ~ ., data = trainingSet) 
        summary(base)
        fit <- step(base, direction = "both")
        summary(fit)
        predictions <- predict(fit, testSet)
        
        mse <- mean((as.matrix(TestDuration)  - predictions)^2)
        mae <- mean(abs(as.matrix(TestDuration)  - predictions))
        mape <- mean(abs(as.matrix(TestDuration)  - predictions/predictions))
        # mpe <- mean(as.matrix(TestDuration)  - predictions/predictions)
        # smape = mean((abs(as.matrix(predictions)  -TestDuration)/ (abs(TestDuration) + abs(predictions))/2 ))
        
        Acc <- predictions/TestDuration
        AccMin <- min(Acc)
        AccMean <- mean(as.matrix(Acc))
        AccMedian <- median(as.matrix(Acc))
        AccMax <- max(Acc)
        AccSD <- sd(as.matrix(Acc))
        
        Tempresult <- data.frame(Gpu, App, Size, Block, TestDuration, predictions, Acc, AccMin, AccMax, AccMean, AccMedian, AccSD,mse, mae,mape)

        result <- rbind(result, Tempresult)
        
    }
}
# result
colnames(result) <-c("Gpus", "Apps", "InputSize", "ThreadBlock" , "Measured", "Predicted",  "accuracy", "Min", "max", "Mean", "Median", "SD", "mse", "mae", "mape")
write.csv(result, file = "./R-code/Results/LinearRegression.csv")

Tempresult <- data.frame(Gpu, App, Size, Block, TestDuration, predictions, Acc, AccMin, AccMax, AccMean, AccMedian, AccSD, mse, mae,mape)

result$Apps <- factor(result$Apps, levels =  c("matMul_gpu_uncoalesced","matMul_gpu", "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem",
                                               "matrix_sum_normal", "matrix_sum_coalesced", 
                                               "dotProd", "vectorAdd",  "subSeqMax"))

# result[result$Apps %in% "matrix_sum_normal" & result$Gpus %in% c("Quadro", "TitanX"),]

Graph <- ggplot(data=result, aes(x=Gpus, y=accuracy, group=Gpus, shape=Gpus,col=Gpus)) + 
    geom_boxplot(aes(shape=Gpus),outlier.shape = NA) +
    scale_y_continuous(limits = c(0.25, 1.5)) +
    xlab("GPUs") + 
    ylab(expression(paste("Accuracy ",T[k]/T[m] ))) +
    theme(axis.title = element_text(family = "Times", face="bold", size=22)) +
    theme(axis.text  = element_text(family = "Times", face="bold", size=10)) +
    theme(axis.text.x=element_blank()) +
    theme(legend.title  = element_text(family = "Times", face="bold", size=16)) +
    theme(legend.text  = element_text(family = "Times", face="bold", size=16)) +
    # facet_grid(.~Apps, scales="fixed") 
    facet_wrap(~Apps, ncol=3, scales="free_y") 
    # scale_colour_grey()

# ggsave(paste("./images/ResultLinearRegression.pdf",sep=""), Graph, device = pdf, height=10, width=16)
ggsave(paste("./images/ResultsLearning/ResultLinearRegression.png",sep=""), Graph, height=10, width=16)

# pp<-predict(fit, int="p", newdata=testSet)
# pc<-predict(fit, int="c", newdata=testSet)
# with(testSet, plot(Input.Size, Duration,
#                    ylim=range(Duration, pp, na.rm=T),
#                    xlab="Blood glucose", ylab="Short Velocity",
#                    main="Plot with Confidence and Prediction Bands"))
# matlines(Size, pc, lty=c(1,2,2), col="black")
# matlines(Size, pp, lty=c(1,3,3), col="black")

                
