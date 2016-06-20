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
                    "L2.Read.Transactions",	"L2.Write.Transactions",
                   "blockSize", "GridSize"
)

DataAppGPU <- read.csv(file = paste("./R-code/Datasets/CleanData/matMul_gpu_sharedmem-All.csv", sep = ""))
DataAppGPU <- rbind(DataAppGPU[c(Parameters)])

result <- data.frame()
for (CC in c(1:10)){
    for( j in 4) {
        # if (CC <= 6){
        #     Data <- subset(DataAppGPU, AppId == j & gpu_id <= 6 & gpu_id > 1 & blockSize == 256)
        # } else{
        #     Data <- subset(DataAppGPU, AppId == j & gpu_id > 7 & blockSize == 256)
        # }
            
        
        Data <- subset(DataAppGPU, AppId == j )
        Data <- Data[complete.cases(Data),]
        # Data[["max_clock_rate"]] <- scale(Data[["max_clock_rate"]], center = FALSE, scale = max(Data["totalStoreGM"], na.rm = TRUE))
        
        # trainingSet <- subset(Data, gpu_id != CC | blockSize != 256)
        # testSet <- subset(Data, gpu_id == CC & blockSize == 256)
        
        if (j <= 6){
            trainingSet <- subset(Data, Input.Size <= 4096 | Input.Size >= 6912 | blockSize != 1024)
            testSet <- subset(Data, (Input.Size > 4096 & Input.Size < 6912) & blockSize == 1024)
        } else if(j >  6 & j <9 ){
            trainingSet <- subset(Data, Input.Size <= 71303168 | Input.Size >= 121634816 | blockSize != 256)
            testSet <- subset(Data, (Input.Size > 71303168 & Input.Size < 121634816) & blockSize == 256)
        } else {
            trainingSet <- subset(Data, Input.Size <= 163577856 | Input.Size >= 218103808 )
            testSet <- subset(Data, (Input.Size > 163577856 & Input.Size < 218103808) )
        }
        
        dim(Data)
        dim(trainingSet)
        dim(testSet)
        
        trainingSet$AppName <- NULL
        trainingSet$gpu_name <- NULL
        trainingSet$AppId <- NULL
        trainingSet$gpu_id <- NULL
        
        trainingSet$max_clock_rate <- NULL
        trainingSet$num_of_cores <- NULL 
        trainingSet$Achieved.Occupancy <- NULL
        trainingSet$blockSize <- NULL
        trainingSet$GridSize <- NULL
        
        
        
        TestDuration <- testSet["Duration"]
        Size <- testSet["Input.Size"]
        App <- testSet["AppName"]
        Gpu <- testSet["gpu_name"]
        Block <- testSet["blockSize"]
        
        # "gpu_name","gpu_id", "AppName", "AppId", "Input.Size", "Duration", 
        # "max_clock_rate",	"num_of_cores",	
        # "Achieved.Occupancy",
        # "totalLoadGM", "totalStoreGM", "totalLoadSM", "totalStoreSM",
        # "Device.Memory.Read.Transactions",	"Device.Memory.Write.Transactions",	"L2.Read.Transactions",	"L2.Write.Transactions",
        # "inst_issued2",
        # "blockSize", "GridSize"
        
        testSet$AppName <- NULL
        testSet$gpu_name <- NULL
        testSet$Duration <- NULL
        testSet$AppId <- NULL
        testSet$gpu_id <- NULL

        testSet$max_clock_rate <- NULL
        testSet$num_of_cores <- NULL 
        testSet$Achieved.Occupancy <- NULL
        testSet$blockSize <- NULL
        testSet$GridSize <- NULL
        
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

