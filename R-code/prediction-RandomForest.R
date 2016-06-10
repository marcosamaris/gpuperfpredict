library(randomForest)
library(ggplot2)


dirpath <- "~/Doctorate/svm-gpuperf/"
setwd(paste(dirpath, sep=""))

gpus <- read.table("./R-code/deviceInfo.csv", sep=",", header=T)
NoGPU <- dim(gpus)[1]

apps <- c("matMul_gpu_uncoalesced","matMul_gpu", "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem",
          "matrix_sum_normal", "matrix_sum_coalesced", 
          "dotProd", "vectorAdd",  "subSeqMax")

Parameters_3x <- c("gpu_name","gpu_id", "AppName", "AppId", "Input.Size", "Duration", "max_clock_rate",	"num_of_cores",
                   "Achieved.Occupancy",
                   "Executed.Load.Store.Instructions",
                   "Shared.Load.Transactions",	"Shared.Store.Transactions", "Global.Load.Transactions",	"Global.Store.Transactions",
                   "Global.Load.Transactions.Per.Request",	"Global.Store.Transactions.Per.Request",
                   "Floating.Point.Operations.Single.Precision.","Instructions.Issued",
                   "warps_launched","Block.X")

Parameters_5x <- c("gpu_name","gpu_id",	"AppName", "AppId", "Input.Size", "Duration","max_clock_rate",	"num_of_cores",
                   "Achieved.Occupancy",
                   "Executed.Load.Store.Instructions",
                   "Shared.Load.Transactions",	"Shared.Store.Transactions", "Global.Load.Transactions",	"Global.Store.Transactions",
                   "Global.Load.Transactions.Per.Request",	"Global.Store.Transactions.Per.Request",
                   
                   "Floating.Point.Operations.Single.Precision.","Instructions.Issued",
                   "warps_launched","Block.X")
length(Parameters_3x)
length(Parameters_5x)

DataAppGPU30 <- read.csv(file = paste("./R-code/Datasets/AppGPU30.csv", sep = ""))
DataAppGPU35 <- read.csv(file = paste("./R-code/Datasets/AppGPU35.csv", sep = ""))
DataAppGPU50 <- read.csv(file = paste("./R-code/Datasets/AppGPU50.csv", sep = ""))
DataAppGPU52 <- read.csv(file = paste("./R-code/Datasets/AppGPU52.csv", sep = ""))


result <- data.frame()
# write.csv(Data, file = "./R-code/Datasets/CleanData/App-GPU-CC-5X.csv")
for (CC in c(3,5)){
    if (CC == 3 ){
        DataAppGPU <- rbind(DataAppGPU30[Parameters_3x], DataAppGPU35[Parameters_3x])
        GPU <- 2
    } else {
        DataAppGPU <- rbind(DataAppGPU50[Parameters_3x], DataAppGPU52[Parameters_5x])
        GPU <- 2
    }
    for( j in 1:9) {
        
        
        Data <- subset(DataAppGPU, AppId == j )
        Data <- Data[complete.cases(Data),]
        dim(Data)
        # View(Data)
        # summary(Data)
        # DataAppGPU35 <- DataAppGPU35[sapply(DataAppGPU35,is.numeric)]
        # DataAppGPU35 <- DataAppGPU35[,-(which(colSums(DataAppGPU35) == 0))]
        # 
        
        if (j < 5) {
            lowerLimit <- 2048
            uperLimit <- 4096
            blockSize <- 16
        } else if (j >= 5 & j < 7) {
            lowerLimit <- 4096
            uperLimit <- 5376
            blockSize <- 16
        } else {
            lowerLimit <- 50331648
            uperLimit <- 58720256
            blockSize <- 256
        }
        
        if (j < 9) {
            trainingSet <- subset(Data, gpu_id != GPU)
            testSet <- subset(Data, gpu_id == GPU)
            dim(trainingSet)
            dim(testSet)
        } else {
            trainingSet <- subset(Data, gpu_id != GPU)
            testSet <- subset(Data, gpu_id == GPU)
        }
        
        
        trainingSet$AppName <- NULL
        trainingSet$gpu_name <- NULL
        trainingSet$gpu_id <- NULL
        trainingSet$AppId <- NULL
        # trainingDuration <- trainingSet["Duration"]
        # trainingSet$Duration <- NULL
        dim(trainingSet)
        
        TestDuration <- testSet["Duration"]
        Size <- testSet["Input.Size"]
        App <- testSet["AppName"]
        Gpu <- testSet["gpu_name"]
        Block <- testSet["Block.X"]
        
        testSet$AppName <- NULL
        testSet$gpu_name <- NULL
        testSet$gpu_id <- NULL
        testSet$Duration <- NULL
        testSet$AppId <- NULL
        dim(testSet)
        
        fit <- randomForest(trainingSet$Duration ~ ., data = trainingSet,mtry = 10, importance = TRUE,do.trace = 100)
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
result
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
