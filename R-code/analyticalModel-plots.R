library("data.table")
library("plyr")
library("ggplot2")

dirpath <- "~/Dropbox/Doctorate/GIT/BSyncGPGPU/"
setwd(paste(dirpath, sep = ""))

source("./code/include/common.R")
source("./code/include/sharedFunctions.R")

set.seed(5)

namesTraces <- read.csv("./data/tracesNames.csv",header = T, sep = ",")

tempFeatures <- data.frame()
for (kernelApp in c(6)) {
  tempApps <- data.frame()
  for (gpu in c(1, 2, 8, 9)) {
    
    tempAppGpu <- read.csv(paste("./datasets/", names(kernelsDict[kernelApp]), "-", gpus[gpu,'gpu_name'], ".csv", sep=""))
    N <- count(tempAppGpu$input.size.1)["x"]
    M <- count(tempAppGpu$input.size.2)["x"]
    
    dir.create(file.path(dirpath, paste("./images/analyticalModel/", names(kernelsDict[kernelApp]), "/", 
                                        gpus[gpu,'gpu_name'], "/", sep = "")), showWarnings = FALSE)
    # setwd(file.path(mainDir, subDir))
    
    for (features in 2:length(tempAppGpu)){
      png(filename =  paste("./images/analyticalModel/", names(kernelsDict[kernelApp]), "/", gpus[gpu,'gpu_name'], "/", names(tempAppGpu[features]),  
                            ".png", sep = ""), units = "px", width = 1600, height = 1600)
      par(mfrow = c(5,4))
        for (i in 1:5){
          for (j in 1:4){
            tempFeature <- subset(tempAppGpu, input.size.1 == N[i,] & input.size.2 == M[j,])
            plot(tempFeature[,features],  xlab="Execution number", ylab="Value", main=paste(N[i,], " - ", M[j,], sepo=""), cex=1, cex.lab=2, 
               cex.main=3, cex.axis=2)
          }
        }
      dev.off()
    }
  }
}
