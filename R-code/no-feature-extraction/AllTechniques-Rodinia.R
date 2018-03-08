library("plyr")
result_Global <- data.frame()

Result_LM <- read.csv(file = "results/LinearRegression-Rodinia-fair.csv")
Result_SVM <- read.csv(file = "results/SVM-Rodinia-fair.csv")
Result_RF <- read.csv(file = "results/RF-Rodinia-fair.csv")

Result_LM$Technique <- "Linear Regression"
Result_SVM$Technique <- "SVM"
Result_RF$Technique <- "RF"

result_Global <- rbind(Result_LM, Result_SVM, Result_RF)

result_Global$CUDAKernels <- factor(result_Global$CUDAKernels, levels = c("BCK-K1", "BCK-K2",  "GAU-K1", "GAU-K2", "HTW",  "HOT",  "H3D","LMD", "LUD-K1", "LUD-K2", "LUD-K3", "NDL-K1", "NDL-K2"))


result_Global$GPUs <- factor(result_Global$GPUs, levels = c("GTX-680", "Tesla-K20", "Tesla-K40", "Titan", "Quadro",  "TitanX", "GTX-970", "GTX-980", "Tesla-P100"))

result_Global <- subset(result_Global, GPUs %in% c("Tesla-K20",  "Tesla-K40", "Titan", "GTX-980", "Tesla-P100"))


Graph <- ggplot(data=result_Global, aes(x=GPUs, y=acc, group=GPUs, col=GPUs)) + 
    geom_boxplot( size=1, outlier.size = 1) +  scale_y_continuous(limits =  c(0, 2)) +
    stat_boxplot(geom ='errorbar') +
    xlab("Machine Learning Techniques") + 
    theme_bw() +
    # scale_colour_manual(values=c(cbbPalette, "blue")) +
    # scale_fill_manual(values=c(cbbPalette, "blue")) +
    ggtitle("Accuracy Rodinia Kernels with ML techniques - NO features extraction") +
    ylab(expression(paste("Accuracy ",T[k]/T[m] ))) +
    theme(plot.title = element_text(family = "Times", face="bold", size=12, colour = "Black")) +
    theme(plot.title = element_text(hjust = 0.5)) +
    theme(axis.title = element_text(family = "Times", face="bold", size=12, colour = "Black")) +
    theme(axis.text  = element_text(family = "Times", face="bold", size=8, colour = "Black")) +
    theme(axis.text.x=element_blank()) +
    theme(legend.title  = element_text(family = "Times", face="bold", size=0, colour = "Black")) +
    theme(legend.title.align=0.5) +
    theme(legend.text  = element_text(family = "Times", face="bold", size=12, colour = "Black")) +
    theme(legend.key.size = unit(5, "cm")) +
    theme(legend.direction = "horizontal",
    legend.position = "bottom",
          legend.key=element_rect(size=0),
          legend.key.size = unit(2.25, "lines")) +
  guides(col = guide_legend(nrow = 1)) +
    facet_grid(CUDAKernels~Technique, scales="free") +
    theme(strip.text = element_text(size=8, family = "Times", face="bold", colour = "Black")) +
    scale_colour_grey()

ggsave(paste("./images/ResultTechniques-Rodinia-fair.pdf",sep=""), Graph, height=24, width=16, units="cm")


Result_AM <- read.csv(file = "results/BSP-based-model-Rodinia.csv")
Result_AM$predicted <- as.numeric(as.character(Result_AM$predicted))
Result_AM$measured <- as.numeric(as.character(Result_AM$measured))

CUDAKernel <- c("BCK-K1", "BCK-K2",  "GAU-K1", "GAU-K2", "HTW",  "HOT",  "H3D","LMD", "LUD-K1", "LUD-K2", "LUD-K3", "NDL-K1", "NDL-K2")

for(i in c(2:4, 8:9)){
  for (j in c(1:6, 9:13)){
    Result_AM$mape[Result_AM$gpu == as.character(gpus[i, "gpu_name"]) & Result_AM$CUDAKernels == CUDAKernel[j]] <-
      mean(abs(Result_AM$measured[Result_AM$GPUs == as.character(gpus[i, "gpu_name"]) & Result_AM$CUDAKernels == as.character(CUDAKernel[j])] -
                 Result_AM$predicted[Result_AM$GPUs == as.character(gpus[i, "gpu_name"]) & Result_AM$CUDAKernels == as.character(CUDAKernel[j])])/
             abs(Result_AM$predicted[Result_AM$GPUs == as.character(gpus[i, "gpu_name"]) & Result_AM$CUDAKernels == as.character(CUDAKernel[j])]))*100
  }
}

Result_LM <- read.csv(file = "results/LinearRegression-Rodinia-fair.csv")
Result_RF <- read.csv(file = "results/RF-Rodinia-fair.csv")
Result_SVM <- read.csv(file = "results/SVM-Rodinia-fair.csv")

AMMAPE <- count(Result_AM, c("CUDAKernels", "GPUs", "mape"))
LMMAPE <- count(Result_LM, c("CUDAKernels", "GPUs", "mape"))
RFMAPE <- count(Result_RF, c("CUDAKernels", "GPUs", "mape"))
SVMMAPE <- count(Result_SVM, c("CUDAKernels", "GPUs", "mape"))


for(i in c(1:6, 9:13)){
  print(paste(CUDAKernel[i], " & ",  
              sprintf("%.2f", mean(AMMAPE$mape[AMMAPE$CUDAKernels ==  as.character(CUDAKernel[i])])), "$\\pm$", 
              sprintf("%.2f", sd(AMMAPE$mape[AMMAPE$CUDAKernels ==  as.character(CUDAKernel[i])])), "&", 
              sprintf("%.2f", mean(LMMAPE$mape[LMMAPE$CUDAKernels ==  as.character(CUDAKernel[i])])), "$\\pm$", 
              sprintf("%.2f", sd(LMMAPE$mape[LMMAPE$CUDAKernels ==  as.character(CUDAKernel[i])])), "&", 
              sprintf("%.2f", mean(RFMAPE$mape[RFMAPE$CUDAKernels ==  as.character(CUDAKernel[i])])), "$\\pm$", 
              sprintf("%.2f", sd(RFMAPE$mape[RFMAPE$CUDAKernels ==  as.character(CUDAKernel[i])])), "&",
              sprintf("%.2f", mean(SVMMAPE$mape[SVMMAPE$CUDAKernels ==  as.character(CUDAKernel[i])])), "$\\pm$", 
              sprintf("%.2f", sd(SVMMAPE$mape[SVMMAPE$CUDAKernels ==  as.character(CUDAKernel[i])])), "\\ \\midrule", sep=""))
}
