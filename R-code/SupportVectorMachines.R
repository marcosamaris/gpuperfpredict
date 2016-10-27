library(e1071)
library(ggplot2)
library(plyr)

dirpath <- "~/Dropbox/Doctorate/svm-gpuperf/"
setwd(paste(dirpath, sep=""))

gpus <- read.table("./Datasets/deviceInfo.csv", sep=",", header=T)
NoGPU <- dim(gpus)[1]

apps <- c("matMul_gpu_uncoalesced","matMul_gpu", "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem",
          "matrix_sum_normal", "matrix_sum_coalesced", 
          "dotProd", "vectorAdd",  "subSeqMax")

Parameters <- c("gpu_name","gpu_id", "AppName", "AppId", "Input.Size", "Duration", 
                "max_clock_rate",	"num_of_cores",	"bandwith",
                "Achieved.Occupancy",
                "totalLoadGM", "totalStoreGM", "totalLoadSM", "totalStoreSM",
                "Floating.Point.Operations.Single.Precision.",
                "L2.Read.Transactions",	"L2.Write.Transactions",
                "blockSize", "GridSize", "totalThreads"
)


DataAppGPU <- read.csv(file = paste("./Datasets/CleanData/App-GPU-CC-All.csv", sep = ""))
DataAppGPU <- rbind(DataAppGPU[c(Parameters)])


result <- data.frame()
for (CC in c(1:6, 8:10)){
    for( j in 1:9) {
        Data <- subset(DataAppGPU, AppId == j)
        
        if (j == 3 | j == 4 ){
            print(j)
        } else if (j == 9){
            Data$Floating.Point.Operations.Single.Precision. <- NULL
        } else {
            Data$totalLoadSM <- NULL
            Data$totalStoreSM <- NULL
        }
        Data <- Data[complete.cases(Data),]
        Data$bandwith <- Data$bandwith
        Data$num_of_cores <- Data$num_of_cores
        
        trainingSet <- subset(Data, gpu_id != CC)
        testSet <- subset(Data, gpu_id == CC )
        
        dim(Data)
        dim(trainingSet)
        dim(testSet)
        
        trainingSet$AppName <- NULL
        trainingSet$gpu_name <- NULL
        trainingSet$AppId <- NULL
        trainingSet$gpu_id <- NULL
        trainingSet$L2.Read.Transactions <- NULL
        trainingSet$L2.Write.Transactions <- NULL
        
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
        testSet$L2.Read.Transactions <- NULL
        testSet$L2.Write.Transactions <- NULL
        
        trainingSet <- log(trainingSet,3)
        testSet <- log(testSet,3)
        
        fit <- svm(trainingSet$Duration ~ ., data = trainingSet, kernel="linear", scale=FALSE) 
        summary(fit)
        predictions <- predict(fit, testSet)
        predictions <- 3^predictions
        
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

result$Apps <- revalue(result$Apps, c("matMul_gpu_uncoalesced"="matMul_GM_uncoalesced", "matMul_gpu"="matMul_GM_coalesced", 
                                      "matMul_gpu_sharedmem_uncoalesced"="matMul_SM_uncoalesced", "matMul_gpu_sharedmem"="matMul_SM_coalesced",
                                      "matrix_sum_normal"="matrix_sum_uncoalesced"))

result$Gpus <- factor(result$Gpus, levels = c("Tesla-K40",  "Tesla-K20", "Quadro", "Titan", "TitanBlack", "TitanX", "GTX-680","GTX-980",    "GTX-970",    "GTX-750"))


Result_SVM <- result
Graph <- ggplot(data=result, aes(x=Gpus, y=accuracy, group=Gpus, col=Gpus)) + 
    geom_boxplot( size=1.5, outlier.size = 2.5) + scale_y_continuous(limits =  c(0, 2.5)) +
    stat_boxplot(geom ='errorbar') +
    xlab(" ") + 
    theme_bw() +
    ggtitle("Support Vector Machines") +
    ylab(expression(paste("Accuracy ",T[k]/T[m] ))) +
    theme(plot.title = element_text(family = "Times", face="bold", size=40)) +
    theme(axis.title = element_text(family = "Times", face="bold", size=30)) +
    theme(axis.text  = element_text(family = "Times", face="bold", size=20, colour = "Black")) +
    theme(axis.text.x=element_blank()) +
    theme(legend.title  = element_text(family = "Times", face="bold", size=0)) +
    theme(legend.text  = element_text(family = "Times", face="bold", size=20)) +
    theme(legend.direction = "horizontal", 
          legend.position = "bottom",
          legend.key=element_rect(size=0),
          legend.key.size = unit(5, "lines")) +
    # facet_grid(.~Apps, scales="fixed") 
    facet_wrap(~Apps, ncol=3, scales="free_y") +
    theme(strip.text = element_text(size=20))

ggsave(paste("./images/SupportVectorMachine.pdf",sep=""), Graph, device = pdf, height=10, width=16)
write.csv(result, file = "./Results/SVM.csv")

