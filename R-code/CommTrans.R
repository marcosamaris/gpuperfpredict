dirpath <- "~/Dropbox/Doctorate/Results/2016/svm-gpuperf/data/"
library(ggplot2)
library(reshape)

setwd(paste(dirpath, sep=""))
cbbPalette <- gray(1:6/ 8)#c("red", "blue", "darkgray", "orange","black","brown", "lightblue","violet")
tracesName  <- read.csv(paste("./tracesName.csv",sep=","),header = TRUE)


Nn <- 16:28
N <- 2^Nn
SizeB <- c("0.25 MB", "0.5 MB", "1 MB",    "2 MB",    "4 MB",    "8 MB",    "16 MB",   "32 MB",   "64 MB",   "128 MB",  "256 MB",  "512 MB", "1024 MB")

gpus <- c("GeForce-980", "GeForce-750", "Titan", "Tesla-K40", "Tesla-K20")
apps <- c("transFloat", "transDouble", "transComplexFloat", "transComplexDouble")


for (j in 1:length(apps)){
    HtoD <- list()
    for (i in 1:length(gpus)){
        temp <- read.csv(paste("./", gpus[i], "/", apps[j], "-HtoD-traces.csv",sep=""),header = FALSE)
        x <- dim(temp)
        HtoD[[i]] <- cbind(N[1:x[1]], SizeB[1:x[1]], gpus[i], temp)
    }
    Matrix = do.call(rbind, HtoD)
    colnames(Matrix) <- c("Size", "sizeB", "GPUs", names(tracesName))
    Matrix <- as.data.frame(Matrix)
    Matrix$sizeB = factor(Matrix$sizeB, levels = c("0.25 MB", "0.5 MB", "1 MB",    "2 MB",    "4 MB",    "8 MB",    "16 MB",   "32 MB",   "64 MB",   "128 MB",  "256 MB",  "512 MB", "1024 MB"))
    
    if(apps[j] == "transFloat"){
        Title <- "HtoD - Float Data Transference"    
    }
    if(apps[j] == "transDouble"){
        Title <- "HtoD - Double Data Transference"
    }
    if(apps[j] == "transComplexFloat"){
        Title <- "HtoD - Complex Float Data Transference"    
    }
    if(apps[j] == "transComplexDouble"){
        Title <- "HtoD - Complex Double Data Transference"  
    }
    
    Graph <- ggplot(data=Matrix, aes(x=sizeB, y=Duration, group=Device, color = Device)) +   
        geom_line(size=2,aes(linetype=Device)) + geom_point(size=3) + 
        scale_y_log10(breaks = scales::trans_breaks("log10", function(x) 10^x),
                      labels = scales::trans_format("log10", scales::math_format(10^.x)))  + 
        annotation_logticks(sides = "l")  + 
        xlab("Size (Bytes)") + ylab("Time (sec)") + ggtitle(Title)    +
        theme(plot.title = element_text(family = "Trebuchet MS", face="bold", size=32)) +
        theme(axis.title = element_text(family = "Trebuchet MS", face="bold", size=22)) +
        theme(legend.title  = element_text(family = "Trebuchet MS", face="bold", size=14)) +
        theme(legend.text  = element_text(family = "Trebuchet MS", face="bold", size=14)) +
        theme(axis.text  = element_text(family = "Trebuchet MS", face="bold", size=12)) 
        
        ggsave(paste("../images/HtoD-", apps[j], ".png",sep=""), Graph,height=10, width=16)
}


for (j in 1:length(apps)){
    DtoH <- list()
    for (i in 1:length(gpus)){
        temp <- read.csv(paste("./", gpus[i], "/", apps[j], "-DtoH-traces.csv",sep=""),header = FALSE)
        x <- dim(temp)
        DtoH[[i]] <- cbind(N[1:x[1]], SizeB[1:x[1]], gpus[i], temp)
    }
    Matrix = do.call(rbind, DtoH)
    colnames(Matrix) <- c("Size", "sizeB", "GPUs", names(tracesName))
    Matrix <- as.data.frame(Matrix)
    Matrix$sizeB = factor(Matrix$sizeB, levels = c("0.25 MB", "0.5 MB", "1 MB",    "2 MB",    "4 MB",    "8 MB",    "16 MB",   "32 MB",   "64 MB",   "128 MB",  "256 MB",  "512 MB", "1024 MB"))
    
    if(apps[j] == "transFloat"){
        Title <- "DtoH - Float Data Transference"    
    }
    if(apps[j] == "transDouble"){
        Title <- "DtoH - Double Data Transference"
    }
    if(apps[j] == "transComplexFloat"){
        Title <- "DtoH - Complex Float Data Transference"    
    }
    if(apps[j] == "transComplexDouble"){
        Title <- "DtoH - Complex Double Data Transference"  
    }
    
    Graph <- ggplot(data=Matrix, aes(x=sizeB, y=Duration, group=Device, color = Device)) +   
        geom_line(size=2,aes(linetype=Device)) + geom_point(size=3) + 
        scale_y_log10(breaks = scales::trans_breaks("log10", function(x) 10^x),
                      labels = scales::trans_format("log10", scales::math_format(10^.x))) + 
        annotation_logticks(sides = "l") + 
        xlab("Size (Bytes)") + ylab("Time (sec)") + ggtitle(Title)    +
        theme(plot.title = element_text(family = "Trebuchet MS", face="bold", size=32)) +
        theme(axis.title = element_text(family = "Trebuchet MS", face="bold", size=22)) +
        theme(legend.title  = element_text(family = "Trebuchet MS", face="bold", size=14)) +
        theme(legend.text  = element_text(family = "Trebuchet MS", face="bold", size=14)) +
        theme(axis.text  = element_text(family = "Trebuchet MS", face="bold", size=12)) 
    
    ggsave(paste("../images/DtoH-", apps[j], ".png",sep=""), Graph,height=10, width=16)
}

sapply(Matrix,class)
levels(Matrix$Duration)
