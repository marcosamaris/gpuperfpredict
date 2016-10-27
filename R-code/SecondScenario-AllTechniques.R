
result_Global <- data.frame()

# Result_AM$Predicted <- as.numeric(levels(Result_AM$Predicted))[Result_AM$Predicted]
# Result_LM$Predicted <- as.numeric(Result_LM$Predicted)
# Result_SVM$Predicted <- as.numeric(Result_SVM$Predicted)
# Result_RF$Predicted <- as.numeric(Result_RF$Predicted)


dataTemp$Apps <- revalue(dataTemp$Apps, c("matMul_gpu_uncoalesced"="matMul_GM_uncoalesced", "matMul_gpu"="matMul_GM_coalesced", 
                                          "matMul_gpu_sharedmem_uncoalesced"="matMul_SM_uncoalesced", "matMul_gpu_sharedmem"="matMul_SM_coalesced",
                                          "matrix_sum_normal"="matrix_sum_uncoalesced"))

App <- c("matMul_GM_uncoalesced", "matMul_GM_coalesced", "matMul_SM_uncoalesced","matMul_SM_coalesced",
        "matrix_sum_uncoalesced", "matrix_sum_coalesced", 
        "dotProd", "vectorAdd",  "subSeqMax")

mse <- array()
mae <- array()
mape <- array()
rmse <- array()
for (i in 1:9){
    Data <- subset(Result_RF, Apps == App[i])
    mse[i] <- mean((as.matrix(Data$Measured)  - Data$Predicted)^2)
    mae[i] <- mean(abs(as.matrix(Data$Measured)  - Data$Predicted))
    mape[i] <- mean(abs((as.matrix(Data$Measured)  - Data$Predicted)/Data$Predicted))*100
    rmse[i] <- sqrt(mean((as.matrix(Data$Measured)  - Data$Predicted)^2))
}
mse
mae
mape
rmse



Result_AM$Technique <- "Analytical"
Result_LM$Technique <- "LM"
Result_SVM$Technique <- "SVM"
Result_RF$Technique <- "RF"


result_Global <- rbind(Result_AM, Result_LM,Result_SVM,Result_RF)

result_Global$Apps <- revalue(result_Global$Apps, c("matMul_GM_uncoalesced"="MMGU", "matMul_GM_coalesced"="MMGC", 
                                      "matMul_SM_uncoalesced"="MMSU", "matMul_SM_coalesced"="MMSC",
                                      "matrix_sum_uncoalesced"="MAU", "matrix_sum_coalesced"="MAC",
                                      "vectorAdd"= "vAdd", "dotProd"="dotP","subSeqMax"="MSA"))

Graph <- ggplot(data=result_Global, aes(x=Gpus, y=accuracy, group=Gpus, col=Gpus)) + 
    geom_boxplot( size=2, outlier.size = 2.5) + scale_y_continuous(limits =  c(0, 2.5)) +
    stat_boxplot(geom ='errorbar') +
    xlab(" ") + 
    theme_bw() +
    ggtitle("Accuracy of the compared techniques ") +
    ylab(expression(paste("Accuracy ",T[k]/T[m] ))) +
    theme(plot.title = element_text(family = "Times", face="bold", size=40)) +
    theme(axis.title = element_text(family = "Times", face="bold", size=35)) +
    theme(axis.text  = element_text(family = "Times", face="bold", size=25, colour = "Black")) +
    theme(axis.text.x=element_blank()) +
    theme(legend.title  = element_text(family = "Times", face="bold", size=0)) +
    theme(legend.text  = element_text(family = "Times", face="bold", size=30)) +
    theme(legend.key.size = unit(5, "cm")) +
    theme(legend.direction = "horizontal",
    legend.position = "bottom",
          legend.key=element_rect(size=0),
          legend.key.size = unit(3, "lines")) +
    guides(col = guide_legend(nrow = 1)) +
    facet_grid(Apps~Technique, scales="fixed") +
    theme(strip.text = element_text(size=25, family = "Times", face="bold"))

ggsave(paste("./images/ResultTechniques.pdf",sep=""), Graph, device = cairo_pdf, height=30, width=21)
