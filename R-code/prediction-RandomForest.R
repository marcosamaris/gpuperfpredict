library(randomForest)
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

for (CC in c(7:10)){
    for( j in 1:9) {
        Data <- subset(DataAppGPU, AppId == j )
        dim(Data)
        
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
        
        fit <- randomForest(trainingSet$Duration ~ ., data = trainingSet, importance = TRUE,do.trace = 100)
        print(fit)
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
write.csv(result, file = "./R-code/Results/RandomForest-4.csv")

Tempresult <- data.frame(Gpu, App, Size, Block, TestDuration, predictions, Acc, AccMin, AccMax, AccMean, AccMedian, AccSD, mse, mae,mape)

result$Apps <- factor(result$Apps, levels =  c("matMul_gpu_uncoalesced","matMul_gpu", "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem",
                                               "matrix_sum_normal", "matrix_sum_coalesced", 
                                               "dotProd", "vectorAdd",  "subSeqMax"))

# result[result$Apps %in% "matrix_sum_normal" & result$Gpus %in% c("Quadro", "TitanX"),]

Graph <- ggplot(data=result, aes(x=Gpus, y=accuracy, group=Gpus, shape=Gpus,col=Gpus)) + 
    geom_boxplot(aes(shape=Gpus,stat="identity")) +
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
# Graph

# ggsave(paste("./images/ResultRandomForest.pdf",sep=""), Graph, device = pdf, height=10, width=16)
ggsave(paste("./images/ResultsLearning/ResultRandomForest-4.png",sep=""), Graph, height=10, width=16)
