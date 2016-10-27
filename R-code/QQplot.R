library(e1071)
library(ggplot2)
library(car)

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
                "Floating.Point.Operations.Single.Precision.",
                "L2.Read.Transactions",	"L2.Write.Transactions",
                "blockSize", "GridSize", "totalThreads"
)

DataAppGPU <- read.csv(file = paste("./R-code/Datasets/CleanData/matMul_gpu_sharedmem-All.csv", sep = ""))
DataAppGPU <- rbind(DataAppGPU[c(Parameters)])

Data <- subset(DataAppGPU, Input.Size >= 256 )
Data <- Data[complete.cases(Data),]
# Data[["max_clock_rate"]] <- scale(Data[["max_clock_rate"]], center = FALSE, scale = max(Data["totalStoreGM"], na.rm = TRUE))

trainingSet <- subset(Data, gpu_id != CC)
testSet <- subset(Data, gpu_id == CC )

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

# trainingSet$max_clock_rate <- NULL
# trainingSet$num_of_cores <- NULL
# trainingSet$Achieved.Occupancy <- NULL
# trainingSet$blockSize <- NULL
# trainingSet$GridSize <- NULL
# trainingSet$totalThreads <- NULL
# trainingSet$inst_issued2 <- NULL
trainingSet$L2.Read.Transactions <- NULL
trainingSet$L2.Write.Transactions <- NULL
# trainingSet$totalStoreGM <- NULL

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

# testSet$max_clock_rate <- NULL
# testSet$num_of_cores <- NULL
# testSet$Achieved.Occupancy <- NULL
# testSet$blockSize <- NULL
# testSet$GridSize <- NULL
# testSet$totalThreads <- NULL
# testSet$inst_issued2 <- NULL
testSet$L2.Read.Transactions <- NULL
testSet$L2.Write.Transactions <- NULL
# testSet$totalStoreGM <- NULL


cairo_pdf("./images/ResultsLearning/QQplot.pdf", height=8, width=16)
par(family = "Times", mfrow=c(1,2), mai = c(1, 1, 0.5, 0.5))
base <- rstandard(lm(trainingSet$Duration ~ ., data = trainingSet))
qqnorm(base, ylab="Studentized Residual (Fitted Model)", 
            xlab="t Quantiles", 
            main="Original Data Input", cex.lab = 2.5, cex.main=2.5,cex=1.5,cex.axis=2)
qqline(base, col = 2,lwd=5)

trainingSet <- log(trainingSet,2)
testSet <- log(testSet,2)
base <- rstandard(lm(trainingSet$Duration ~ ., data = trainingSet))
qqnorm(base, ylab="Studentized Residual (Fitted Model)", 
       xlab="t Quantiles", 
       main="Data in Log Scale", cex.lab = 2.5, cex.main=2.5,cex=1.75, cex.axis=2)
qqline(base, col = 2,lwd=5)
dev.off()

