library("plyr")
result_Global <- data.frame()

Result_LM <- read.csv(file = "results/LinearRegression-NCA-fair.csv")
Result_SVM <- read.csv(file = "results/SVM-NCA-fair.csv")
Result_RF <- read.csv(file = "results/RandomForest-NCA-fair.csv")

Result_LM$Technique <- "Linear Regression"
Result_SVM$Technique <- "SVM"
Result_RF$Technique <- "RF"

result_Global <- rbind(Result_LM, Result_SVM, Result_RF)

result_Global$Gpu <- factor(result_Global$Gpu, levels = c("GTX-680", "Tesla-K20", "Tesla-K40", "Titan", "Quadro",  "TitanX", "GTX-970", "GTX-980", "Tesla-P100"))

result_Global <- subset(result_Global, Gpu %in% c("Tesla-K20",  "Tesla-K40", "Titan", "GTX-980", "Tesla-P100"))

Graph <- ggplot(data=result_Global, aes(x=Gpus, y=accuracy, group=Gpus, col=Gpus)) + 
    geom_boxplot( size=1, outlier.size = 1) +  scale_y_continuous(limits =  c(0, 2.5)) +
    stat_boxplot(geom ='errorbar') +
    xlab("Machine Learning Techniques") + 
    theme_bw() +
    # scale_colour_manual(values=c(cbbPalette, "blue")) +
    # scale_fill_manual(values=c(cbbPalette, "blue")) +
    ggtitle("Accuracy Vector/Matrix Kernels with ML techniques - NO features extraction") +
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
    facet_grid(Apps~Technique, scales="free") +
    theme(strip.text = element_text(size=10, family = "Times", face="bold", colour = "Black")) +
  scale_colour_grey()

ggsave(paste("./images/ResultTechniques-fair.pdf",sep=""), Graph, height=24, width=16, units="cm")


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



Result_LM <- read.csv(file = "results/LinearRegression-NCA-fair.csv")
Result_RF <- read.csv(file = "results/RandomForest-NCA-fair.csv")
Result_SVM <- read.csv(file = "results/SVM-NCA-fair.csv")

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
