library("ggplot2")
library("plyr")
result_Global <- data.frame()


dirpath <- "~/Dropbox/Doctorate/Theses/gpuperfpredict/"
setwd(paste(dirpath, sep=""))

source("./R-code/include/common.R")
source("./R-code/include/sharedFunctions.R")


Result_LM <- read.csv(file = "results/context-2-lm.csv")
Result_SVM <- read.csv(file = "results/context-2-svm.csv")
Result_RF <- read.csv(file = "results/context-2-rf.csv")

Result_LM$Technique <- "Linear Regression"
Result_SVM$Technique <- "SVM"
Result_RF$Technique <- "RF"

result_Global <- rbind(Result_LM,  Result_RF, Result_SVM)
# result_Global <- result_Global[result_Global$numberFeatures == 5,]

result_Global$GPUs <- factor(result_Global$GPUs, levels = c("GTX-680", "Tesla-K20", "Tesla-K40", "Titan", "Quadro",  "TitanX", "GTX-970", "GTX-980", "Tesla-P100"))
result_Global <- subset(result_Global, GPUs %in% c("Tesla-K20","Tesla-K40", "TitanX","GTX-980", "Tesla-P100")) 

Graph <- ggplot(data=result_Global, aes(x=GPUs, y=accuracy, group=GPUs, col=GPUs)) + 
    geom_boxplot(size=2, outlier.size = 2.5) + scale_y_continuous(limits =  c(0, 2)) +
    stat_boxplot(geom ='errorbar')  +
    xlab(" ") + 
    theme_bw() +
    ggtitle("Accuracy of the compared techniques in the First Context") +
    ylab(expression(paste("Accuracy ",T[k]/T[m] ))) +
    theme(plot.title = element_text(family = "Times", face="bold", size=16)) +
    theme(plot.title = element_text(hjust = 0.5)) +
    theme(axis.title = element_text(family = "Times", face="bold", size=16)) +
    theme(axis.text  = element_text(family = "Times", face="bold", size=12, colour = "Black")) +
    theme(axis.text.x=element_blank()) +
    theme(legend.title  = element_text(family = "Times", face="bold", size=0)) +
    theme(legend.title.align=0.5) +
    theme(legend.text  = element_text(family = "Times", face="bold", size=14)) +
    theme(legend.key.size = unit(5, "cm")) +
    theme(legend.direction = "horizontal",
    legend.position = "bottom",
          legend.key=element_rect(size=0),
          legend.key.size = unit(3, "lines")) +
  guides(col = guide_legend(nrow = 1)) +
    facet_grid(numberFeatures~Technique, scales="fixed") +
    theme(strip.text = element_text(size=14, family = "Times", face="bold")) +
  scale_colour_grey()
ggsave(paste("./images/context-1/ResultTechniques-Context1.pdf",sep=""), Graph, height=6, width=12)


library("ggplot2")
library("plyr")
result_Global <- data.frame()


dirpath <- "~/Dropbox/Doctorate/Theses/gpuperfpredict/"
setwd(paste(dirpath, sep=""))

source("./R-code/include/common.R")
source("./R-code/include/sharedFunctions.R")


Result_LM <- read.csv(file = "results/context-1-lm.csv")
Result_SVM <- read.csv(file = "results/context-1-svm.csv")
Result_RF <- read.csv(file = "results/context-1-rf.csv")

Result_LM$Technique <- "Linear Regression"
Result_SVM$Technique <- "SVM"
Result_RF$Technique <- "RF"

result_Global <- rbind(Result_LM,  Result_RF, Result_SVM)
# result_Global <- result_Global[result_Global$numberFeatures == 5,]

result_Global$GPUs <- factor(result_Global$GPUs, levels = c("GTX-680", "Tesla-K20", "Tesla-K40", "Titan", "Quadro",  "TitanX", "GTX-970", "GTX-980", "Tesla-P100"))
result_Global <- subset(result_Global, GPUs %in% c("Tesla-K20","Tesla-K40", "TitanX","GTX-980", "Tesla-P100")) 

Graph <- ggplot(data=result_Global, aes(x=GPUs, y=accuracy, group=GPUs, col=GPUs)) + 
  geom_boxplot(size=2, outlier.size = 2.5) + scale_y_continuous(limits =  c(0, 2)) +
  stat_boxplot(geom ='errorbar')  +
  xlab(" ") + 
  theme_bw() +
  ggtitle("Accuracy of the compared techniques in the First Context") +
  ylab(expression(paste("Accuracy ",T[k]/T[m] ))) +
  theme(plot.title = element_text(family = "Times", face="bold", size=16)) +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(axis.title = element_text(family = "Times", face="bold", size=16)) +
  theme(axis.text  = element_text(family = "Times", face="bold", size=12, colour = "Black")) +
  theme(axis.text.x=element_blank()) +
  theme(legend.title  = element_text(family = "Times", face="bold", size=0)) +
  theme(legend.title.align=0.5) +
  theme(legend.text  = element_text(family = "Times", face="bold", size=14)) +
  theme(legend.key.size = unit(5, "cm")) +
  theme(legend.direction = "horizontal",
        legend.position = "bottom",
        legend.key=element_rect(size=0),
        legend.key.size = unit(3, "lines")) +
  guides(col = guide_legend(nrow = 1)) +
  facet_grid(numberFeatures~Technique, scales="fixed") +
  theme(strip.text = element_text(size=14, family = "Times", face="bold")) +
  scale_colour_grey()
ggsave(paste("./images/context-1/ResultTechniques-Context1.pdf",sep=""), Graph, height=6, width=12)





Result_AM <- read.csv(file = "results/BSP-based-model-NCA.csv")
Result_AM$predicted <- as.numeric(as.character(Result_AM$predicted))
Result_AM$measured <- as.numeric(as.character(Result_AM$measured))
for(i in c(2:4, 7:8)){
  for (j in 1:9){
    Result_AM$mape[Result_AM["gpus"] == as.character(gpus[i, "gpu_name"]) & Result_AM["apps"] == CUDAKernel[j]] <-
      mean(abs(Result_AM$measured[Result_AM$gpus == as.character(gpus[i, "gpu_name"]) & Result_AM$apps == as.character(CUDAKernel[j])] -
                 Result_AM$predicted[Result_AM$gpus == as.character(gpus[i, "gpu_name"]) & Result_AM$apps == as.character(CUDAKernel[j])])/
             abs(Result_AM$predicted[Result_AM$gpus == as.character(gpus[i, "gpu_name"]) & Result_AM$apps == as.character(CUDAKernel[j])]))*100
  }
}



Result_LM <- read.csv(file = "results/context-1-lm.csv")
Result_RF <- read.csv(file = "results/context-1-rf.csv")
Result_SVM <- read.csv(file = "results/context-1-svm.csv")

AMMAPE <- count(Result_AM, c("apps", "gpus", "mape"))
LMMAPE <- count(Result_LM, c("apps", "gpus", "mape"))
RFMAPE <- count(Result_RF, c("apps", "gpus", "mape"))
SVMMAPE <- count(Result_SVM, c("apps", "gpus", "mape"))
CUDAKernel <- c("MMGU","MMGC", "MMSU", "MMSC","MAU", "MAC", "dotP", "vAdd", "MSA")

for(i in 1:9){
  print(paste(CUDAKernel[i], " & ",  sprintf("%.2f", mean(AMMAPE$mape[AMMAPE$apps ==  as.character(CUDAKernel[i])])), "$\\pm$", 
              sprintf("%.2f", sd(AMMAPE$mape[AMMAPE$apps ==  as.character(CUDAKernel[i])])), "&", 
              sprintf("%.2f", mean(LMMAPE$mape[LMMAPE$apps ==  as.character(CUDAKernel[i])])), "$\\pm$", 
              sprintf("%.2f", sd(LMMAPE$mape[LMMAPE$apps ==  as.character(CUDAKernel[i])])), "&", 
              sprintf("%.2f", mean(RFMAPE$mape[RFMAPE$apps ==  as.character(CUDAKernel[i])])), "$\\pm$", 
              sprintf("%.2f", sd(RFMAPE$mape[RFMAPE$apps ==  as.character(CUDAKernel[i])])), "&",
              sprintf("%.2f", mean(SVMMAPE$mape[SVMMAPE$apps ==  as.character(CUDAKernel[i])])), "$\\pm$", 
              sprintf("%.2f", sd(SVMMAPE$mape[SVMMAPE$apps ==  as.character(CUDAKernel[i])])), "\\ \\midrule", sep=""))
}
