library(randomForest)
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
                "blockSize", "GridSize", "totalThreads"
)

DataAppGPU <- read.csv(file = paste("./Datasets/CleanData/matMul_gpu_sharedmem-All.csv", sep = ""))
DataAppGPU <- rbind(DataAppGPU[c(Parameters)])

timeMod <- list()
timePred <- list()
result <- data.frame()
for (CC in c(1:6, 8:10)){
    for( j in 4) {
        
        Data <- DataAppGPU[complete.cases(DataAppGPU),]
        
        trainingSet <- subset(Data, gpu_id != CC)
        testSet <- subset(Data, gpu_id == CC )
        
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
        
        trainingSet <- log(trainingSet,2)
        testSet <- log(testSet,2)
        
        fit <- randomForest(trainingSet$Duration ~ ., data = trainingSet, mtry=5,ntree=50)
        
        ptm <- proc.time()
        predictions <- predict(fit, testSet)
        timePred[[CC]] <- proc.time() - ptm
        
        predictions <- 2^predictions
        
        mse <- mean((predictions/TestDuration - 1)^2)
        mae <- mean(abs(as.matrix(TestDuration)  - predictions))
        mape <- mean(abs(as.matrix(TestDuration)  - predictions)/predictions)*100
        
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



# result[result$Apps %in% "matrix_sum_normal" & result$Gpus %in% c("Quadro", "TitanX"),]

Graph <- ggplot(data=result, aes(x=Gpus, y=accuracy, group=Gpus, col=Gpus)) + 
    geom_boxplot( size=2.5, outlier.size = 5) + scale_y_continuous(limits =  c(0, 2.5)) +
    stat_boxplot(geom ='errorbar') +
    xlab(" ") + 
    theme_bw() +
    ggtitle("Random Forest of MMSC") +
    ylab(expression(paste("Accuracy ",T[k]/T[m] ))) +
    theme(plot.title = element_text(family = "Times", face="bold", size=50)) +
    theme(axis.title = element_text(family = "Times", face="bold", size=50)) +
    theme(axis.text  = element_text(family = "Times", face="bold", size=50, colour = "Black")) +
    theme(axis.text.x=element_blank()) +
    theme(legend.title  = element_text(family = "Times", face="bold", size=0)) +
    theme(legend.text  = element_text(family = "Times", face="bold", size=25)) +
    # theme(legend.position = "none") +
    theme(legend.key.size = unit(1, "cm")) +
    theme(legend.direction = "horizontal",
          legend.position = "bottom",
          legend.key=element_rect(size=0),
          legend.key.size = unit(5, "lines")) +
    guides(col = guide_legend(nrow = 2)) 


ggsave(paste("./images/RF-MMSC.pdf",sep=""), Graph, device = pdf, height=10, width=16)
write.csv(result, file = "./Results/RF-MMSC.csv")


