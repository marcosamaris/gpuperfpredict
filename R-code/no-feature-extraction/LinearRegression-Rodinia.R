library(e1071)
library(ggplot2)
library(plyr)

dirpath <- "~/Dropbox/Doctorate/Theses/gpuperfpredict/"
setwd(paste(dirpath, sep=""))

gpus <- read.table("./Datasets/deviceInfo.csv", sep=",", header=T)
NoGPU <- dim(gpus)[1]

apps

Parameters <- c("gpu_name","gpu_id", "AppName", "AppId", "input_size", "duration", 
                   "max_clock_rate",	"num_of_cores",	"bandwith",
                   "achieved_occupancy",
                    "gld_request", "gst_request", "global_load_transactions_per_request", "global_store_transactions_per_request",
                "shared_load_transactions", "shared_store_transactions",
                "floating_point_operations.single_precision.", "warps_launched", "block_x")

DataAppGPU <- read.csv(file = paste("./Datasets/All-App-GPU.csv", sep = ""))
DataAppGPU <- rbind(DataAppGPU[c(Parameters)])

DataAppGPU <- na.omit(DataAppGPU)

result <- data.frame()
for (CC in c(1:8)){
    for( j in 1:9) {
        
        Data <- subset(DataAppGPU, AppId == j)
        
        if (j == 3 | j == 4 ){
            print(j)
        } else if (j == 9){
            Data$floating_point_operations.single_precision. <- NULL
        } else {
            Data$shared_load_transactions <- NULL
            Data$shared_store_transactions <- NULL
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

        TestDuration <- testSet["duration"]
        Size <- testSet["input_size"]
        App <- testSet["AppName"]
        Gpu <- testSet["gpu_name"]
        Block <- testSet["block_x"]

        testSet$AppName <- NULL
        testSet$gpu_name <- NULL
        testSet$duration <- NULL
        testSet$AppId <- NULL
        testSet$gpu_id <- NULL

        testSet$L2.Read.Transactions <- NULL
        testSet$L2.Write.Transactions <- NULL
        
        trainingSet <- log(trainingSet,2)
        testSet <- log(testSet,2)
        
        base <- lm(trainingSet$duration ~ ., data = trainingSet) 
        summary(base)

        predictions <- predict(base, testSet)
        predictions <- 2^predictions
        
        mse <- mean((predictions/TestDuration - 1)^2)
        mae <- mean(abs(as.matrix(TestDuration)  - predictions))
        mape <- mean(abs(as.matrix(TestDuration)  - predictions/predictions))

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

result$Apps <- revalue(result$Apps, c("matMul_gpu_uncoalesced"="MMGU", "matMul_gpu"="MMGC", 
                                          "matMul_gpu_sharedmem_uncoalesced"="MMSU", "matMul_gpu_sharedmem"="MMSC",
                                          "matrix_sum_normal"="MAU", "matrix_sum_coalesced"="MAC", "dotProd" = "dotP", "vectorAdd" = "vAdd", "subSeqMax" = "MSA"))


result$Gpus <- factor(result$Gpus, levels = c("Tesla-K40",  "Tesla-K20", "Quadro", "Titan", "TitanBlack", "TitanX", "GTX-680","GTX-970",    "GTX-980",    "GTX-750"))

result <- result[result$Gpus %in% c("Tesla-K40",  "Tesla-K20", "Titan", "GTX-980",    "GTX-970"),]


Result_LM <- result
Graph <- ggplot(data=result, aes(x=Gpus, y=accuracy, group=Gpus, col=Gpus)) + 
    geom_boxplot( size=1.5, outlier.size = 2.5) + scale_y_continuous(limits =  c(0, 2)) +
    stat_boxplot(geom ='errorbar') +
    xlab(" ") + 
    theme_bw() +
    ggtitle("Accuracy with Linear Regression technique") +
    theme(plot.title = element_text(hjust = 0.5)) +
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
    facet_wrap(~Apps, ncol=3, scales="free") +
    theme(strip.text = element_text(size=20)) +
    scale_colour_grey()

ggsave(paste("./images/LinearRegression-fair.pdf",sep=""), Graph, device = pdf, height=10, width=16)
write.csv(result, file = "./Results/LinearRegression-fair.csv")


