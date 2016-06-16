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

DataAppGPU <- read.csv(file = paste("./R-code/Datasets/CleanData/matMul_gpu_sharedmem-All.csv", sep = ""))
DataAppGPU <- rbind(DataAppGPU[c(Parameters)])

result <- data.frame()
for (CC in c(1:10)){
    for( j in 4) {
        
        Data <- subset(DataAppGPU, AppId == j)
        
        
        
        # Data[["max_clock_rate"]] <- scale(Data[["max_clock_rate"]], center = FALSE, scale = max(Data["totalStoreGM"], na.rm = TRUE))
        # Data[["num_of_cores"]] <- scale(Data[["num_of_cores"]], center = FALSE, scale = max(Data["num_of_cores"], na.rm = TRUE))
        # 
        # Data[["totalLoadGM"]] <- scale(Data[["totalLoadGM"]], center = FALSE, scale = max(Data["totalLoadGM"], na.rm = TRUE))
        # Data[["totalStoreGM"]] <- scale(Data[["totalStoreGM"]], center = FALSE, scale = max(Data["totalStoreGM"], na.rm = TRUE))
        # 
        # if(j == 3 | j == 4 | j == 9){
        #     # Data[["totalLoadSM"]] <- scale(Data[["totalLoadSM"]], center = FALSE, scale = max(Data["totalLoadSM"], na.rm = TRUE))
        #     # Data[["totalStoreSM"]] <- scale(Data[["totalStoreSM"]], center = FALSE, scale = max(Data["totalStoreSM"], na.rm = TRUE))
        # } else {
        #     Data$totalLoadSM <- NULL
        #     Data$totalStoreSM <- NULL
        # }
        
        # if(j != 8){
        #     Data[["inst_issued2"]] <- scale(Data[["inst_issued2"]], center = FALSE, scale = max(Data["inst_issued2"], na.rm = TRUE))
        # }
        
        Data <- Data[complete.cases(Data),]
        
        trainingSet <- subset(Data, gpu_id != CC | blockSize != 256)
        testSet <- subset(Data, gpu_id == CC & blockSize == 256)
        
        # if (j <= 6){
        #     trainingSet <- subset(Data, Input.Size <= 4096 | Input.Size >= 6912 | blockSize != 1024)
        #     testSet <- subset(Data, (Input.Size > 4096 & Input.Size < 6912) & blockSize == 1024)
        # } else if(j >  6 & j <9 ){
        #     trainingSet <- subset(Data, Input.Size <= 71303168 | Input.Size >= 121634816 | blockSize != 256)
        #     testSet <- subset(Data, (Input.Size > 71303168 & Input.Size < 121634816) & blockSize == 256)
        # } else {
        #     trainingSet <- subset(Data, Input.Size <= 163577856 | Input.Size >= 218103808 )
        #     testSet <- subset(Data, (Input.Size > 163577856 & Input.Size < 218103808) )
        # }
        
        dim(Data)
        dim(trainingSet)
        dim(testSet)
        
        trainingSet$AppName <- NULL
        trainingSet$gpu_name <- NULL
        trainingSet$AppId <- NULL
        trainingSet$gpu_id <- NULL
        
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


Tempresult <- data.frame(Gpu, App, Size, Block, TestDuration, predictions, Acc, AccMin, AccMax, AccMean, AccMedian, AccSD, mse, mae,mape)

result$Apps <- factor(result$Apps, levels =  c("matMul_gpu_uncoalesced","matMul_gpu", "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem",
                                               "matrix_sum_normal", "matrix_sum_coalesced", 
                                               "dotProd", "vectorAdd",  "subSeqMax"))

# result[result$Apps %in% "matrix_sum_normal" & result$Gpus %in% c("Quadro", "TitanX"),]

Graph <- ggplot(data=result, aes(x=Gpus, y=accuracy, group=Gpus, shape=Gpus,col=Gpus)) + 
    geom_boxplot(aes(shape=Gpus), size=1.5) +
    xlab("GPUs") + 
    ggtitle("Linear Regression with Outliers") +
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
    facet_wrap(~Apps, ncol=3, scales="free_y") +
    theme(strip.text = element_text(size=20))+
    scale_colour_grey()

ggsave(paste("./images/ResultsLearning/ResultLinearRegression-MSCoalesced-256.pdf",sep=""), Graph, device = pdf, height=10, width=16)
write.csv(result, file = "./R-code/Results/LinearRegression-MSCoalesced-265.csv")
# ggsave(paste("./images/ResultsLearning/ResultLinearRegression.png",sep=""), Graph, height=10, width=16)

