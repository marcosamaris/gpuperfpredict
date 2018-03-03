library("plyr")
result_Global <- data.frame()

# Result_LM <- read.csv(file = "results/phase2/lm-All-App-GPUs.csv")
# Result_SVM <- read.csv(file = "results/phase2/svm-All-App-GPUs.csv")
# Result_RF <- read.csv(file = "results/phase2/rf-All-App-GPUs.csv")

Result_LM$Technique <- "Linear Regression"
Result_SVM$Technique <- "SVM"
Result_RF$Technique <- "RF"

result_Global <- rbind(Result_LM, Result_SVM, Result_RF)
# result_Global <- result_Global[result_Global$numberFeatures == 5,]

# result_Global$GPUs <- factor(result_Global$GPUs, levels = c("GTX-680", "Tesla-K40",  "Tesla-K20", "Titan", "Quadro",  "TitanX", "GTX-970", "GTX-980", "Tesla-P100"))
# result_Global <- subset(result_Global, GPUs %in% c("Tesla-K40", "TitanX", "Quadro","GTX-980", "Tesla-P100")) 

Graph <- ggplot(data=result_Global, aes(x=Gpus, y=accuracy, group=Gpus, col=Gpus)) + 
    geom_boxplot( size=1, outlier.size = 1) +  scale_y_continuous(limits =  c(0, 2.5)) +
    stat_boxplot(geom ='errorbar') +
    xlab("Machine Learning Techniques") + 
    theme_bw() +
    # scale_colour_manual(values=c(cbbPalette, "blue")) +
    # scale_fill_manual(values=c(cbbPalette, "blue")) +
    ggtitle("Compared techniques - same features than Analytical Model") +
    ylab(expression(paste("Accuracy ",T[k]/T[m] ))) +
    theme(plot.title = element_text(family = "Times", face="bold", size=12, colour = "Black")) +
    theme(plot.title = element_text(hjust = 0.5)) +
    theme(axis.title = element_text(family = "Times", face="bold", size=12, colour = "Black")) +
    theme(axis.text  = element_text(family = "Times", face="bold", size=10, colour = "Black")) +
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
# 
# 
# ##### SECOND CONTEXT  
# 
# Result_LM <- read.csv(file = "results/phase3/lm-All-App-GPUs.csv")
# Result_SVM <- read.csv(file = "results/phase3/svm-All-App-GPUs.csv")
# Result_RF <- read.csv(file = "results/phase3/rf-All-App-GPUs.csv")
# 
# Result_LM$Technique <- "Linear Regression"
# Result_SVM$Technique <- "SVM"
# Result_RF$Technique <- "RF"
# 
# result_Global <- data.frame()
# result_Global <- rbind(Result_LM, Result_SVM, Result_RF)
# 
# result_Global$Kernels <- revalue(result_Global$Kernels, c("bpnn_layerforward_CUDA"="BCK-K1", "bpnn_adjust_weights_cuda"="BCK-K2", 
#                                           "Fan1"="GAU-K1", "Fan2"="GAU-K2",
#                                           "kernel"="HWL", "calculate_temp" = "HOT", "hotspotOpt1"="H3D", 
#                                           "lud_diagonal"="LUD-K1", "lud_internal"="LUD-K2", "lud_perimeter"="LUD-K3"))
# 
# result_Global$Kernels <- factor(result_Global$Kernels, levels = c("BCK-K1", "BCK-K2",  "GAU-K1", "GAU-K2", "HWL",  "HOT", "H3D", "LUD-K1",
#                                                             "LUD-K2", "LUD-K3"))
# result_Global <- subset(result_Global, Kernels %in% c("BCK-K2",  "GAU-K1", "HWL", "H3D", "LUD-K1")) 
# result_Global <- result_Global[result_Global$numberFeatures == 5,]
# 
# Graph <- ggplot(data=result_Global, aes(x=Kernels, y=Accuracy, group=Kernels, col=Kernels)) + 
#   geom_boxplot( size=1, outlier.size = 1) + 
#   stat_boxplot(geom ='errorbar') +
#   xlab(" ") + 
#   theme_bw() +
#   scale_colour_manual(values=c(cbbPalette, "blue")) +
#   scale_fill_manual(values=c(cbbPalette, "blue")) +
#   ggtitle("Accuracy of the compared techniques in the Second Context") +
#   ylab(expression(paste("Accuracy ",T[k]/T[m] ))) + scale_y_continuous(limits =  c(0.5, 2)) +
#   theme(plot.title = element_text(family = "Times", face="bold", size=16)) +
#   theme(plot.title = element_text(hjust = 0.5)) +
#   theme(axis.title = element_text(family = "Times", face="bold", size=16)) +
#   theme(axis.text  = element_text(family = "Times", face="bold", size=12, colour = "Black")) +
#   theme(axis.text.x=element_blank()) +
#   theme(legend.title  = element_text(family = "Times", face="bold", size=0)) +
#   theme(legend.title.align=0.5) +
#   theme(legend.text  = element_text(family = "Times", face="bold", size=14)) +
#   theme(legend.key.size = unit(5, "cm")) +
#   theme(legend.direction = "horizontal",
#         legend.position = "bottom",
#         legend.key=element_rect(size=0),
#         legend.key.size = unit(3, "lines")) +
#   guides(col = guide_legend(nrow = 1)) +
#   facet_grid(numberFeatures~Technique, scales="fixed") +
#   theme(strip.text = element_text(size=14, family = "Times", face="bold"))
# ggsave(paste("./images/phase3/ResultTechniques-Context2.pdf",sep=""), Graph, height=10, width=20, units="cm")
# 
# 
# 
# 
# # FIRST CONTEXT 
# 
# pdf(file = "images/parameters.pdf", width = 8,height = 5)
# par(mfrow=c(1, 2), oma=c(0,0,2,0), xpd=TRUE)
# 
# LM_5 <-  c(55.79, 55.57, 55.63, 55.84, 55.19, 59.12, 26.50, 26.50)
# LM_10 <- c(79.76, 80.21, 80.12, 80.26, 83.24, 83.641, 68.84, 68.84)
# Data <- rbind(LM_5, LM_10)
# 
# bp<-barplot(Data, main="Context 1",
#         ylab="Average of MAPE", xlab="Number of GPU Parameters", col=c("blue","red"), names.arg = 1:8,
#          beside=TRUE, legend.text = FALSE)
# text(x = bp, y = Data, label = Data, pos=1,offset =-.5, cex = .5, col = "black")
# 
# # SECOND CONTEXT
# LM_5 <-  c(20.21, 20.21, 20.04, 19.96, 19.04, 18.66, 18.23, 18.16)
# LM_10 <- c(14.00, 14.23, 14.29, 14.20, 13.56, 13.06, 10.85, 10.38)
# Data <- rbind(LM_5, LM_10)
# 
# bp<-barplot(Data, main="Context 2",
#             ylab="Average of MAPE", xlab="Number of GPU Parameters", col=c("blue","red"), names.arg = 1:8,
#             beside=TRUE, legend.text = FALSE)
# legend("topright", c("Case 5 Features", "Case 10 Features"), col=c("blue","red"), lwd=10, inset = c(0,-0.125),cex = .65);
# 
# text(x = bp, y = Data, label = Data, pos=1, offset =-.4,cex = .5, col = "black")
# title("Best number of GPU parameters in each context with Linear Regression", outer=TRUE)
# dev.off()
# 
# 
# #### RANDOM FOREST PARAMETERS GPU
# # FIRST CONTEXT 
# 
# pdf(file = "images/parameters-RF.pdf", width = 8,height = 5)
# par(mfrow=c(1, 2), oma=c(0,0,2,0), xpd=TRUE)
# 
# LM_5 <- c(5.80, 5.19, 5.76, 5.90, 5.71, 6.32, 5.82, 5.99)
# LM_10 <- c(6.16,6.53, 6.42, 6.13, 6.68, 6.39, 6.50, 6.34)
# Data <- rbind(LM_5, LM_10)
# 
# bp<-barplot(Data, main="Context 1",
#             ylab="Average of MAPE", xlab="Number of  GPU Parameters", col=c("blue","red"), names.arg = 1:8,
#             beside=TRUE, legend.text = FALSE)
# text(x = bp, y = Data, label = Data, pos=1,offset =-.5, cex = .5, col = "black")
# 
# # SECOND CONTEXT
# LM_5 <-  c(12.36, 12.39, 12.41, 12.03, 12.47,  12.62, 12.78, 13.49)
# LM_10 <- c(7.12, 7.69, 8.47, 8.70, 8.56, 8.76, 8.32, 8.95)
# Data <- rbind(LM_5, LM_10)
# 
# bp<-barplot(Data, main="Context 2",
#             ylab="Average of MAPE", xlab="Number of GPU Parameters", col=c("blue","red"), names.arg = 1:8,
#             beside=TRUE, legend.text = FALSE)
# legend("topright", c("Case 5 Features", "Case 10 Features"), col=c("blue","red"), lwd=10, inset = c(0.5,-0.05),cex = .65);
# 
# text(x = bp, y = Data, label = Data, pos=1, offset =-.4,cex = .5, col = "black")
# title("Best number of GPU parameters in each context with Random Forests", outer=TRUE)
# dev.off()
# 
# 
# tempData <- tempFeatures[c("elapsed_cycles_sm", "global_store_transactions","issued_control.flow_instructions",
#                     "active_cycles", "multiprocessor_activity", "device_memory_read_transactions",
#                   "executed_load.store_instructions", 
#                   "control.flow_instructions",
#                   "load.store_instructions", "misc_instructions")]
# col <- colorRampPalette(c("blue", "yellow", "red"))(20)
# pdf(file = paste("./images/heatMap_All_App_GPUs.pdf", sep=""), width = 12, height = 6)
# heatmap(x = cor(apply(tempData, 2, normalizeLogMax),
#                 method = "spearman", use = "complete.obs"),
#         col = col, symm = TRUE,cexCol = 1, cexRow = 1.5)
# dev.off()
# 
# 
# names(tempData) <- 1:20
# hcFeatures <- hclust(as.dist(1-abs(cor(apply(tempData, 2, normalizeLogMax),
#                                        method = "spearman", use = "complete.obs"))), method = "average")
# 
# cutedTree <- cutree(hcFeatures, k = numberFeatures)
# nodePar <- list(lab.cex = 0.6, pch = c(NA, 19), 
#                 cex = 0.7, col = "blue")
# pdf(file = paste("./images/cluster-All_App_GPUs.pdf", sep=""), width = 8, height = 5)
# dend <- as.dendrogram(hcFeatures)
# 
# dend %>% color_branches(k=numberFeatures) %>% plot(horiz=FALSE,  nodePar = nodePar, edgePar = list(col = 2:3, lwd = 2:1),
#                                                    main="Dendrogram of the 20 features with 10 Clusters")
# # add horiz rect
# dend %>% rect.dendrogram(k=numberFeatures,horiz=FALSE, lwd = 2:1)
# # add horiz (well, vertical) line:
# abline(h = heights_per_k.dendrogram(dend)[paste(numberFeatures, sep = "")], 
#        lwd = 2, lty = 2, col = "blue")
# # text(50, 50, table(cutedTree))
# dev.off()
# 
# 
# 
# Result_RF$Kernels <- revalue(Result_RF$Kernels, c("bpnn_layerforward_CUDA"="BCK-K1", "bpnn_adjust_weights_cuda"="BCK-K2", 
#                                                           "Fan1"="GAU-K1", "Fan2"="GAU-K2",
#                                                           "kernel"="HWL", "calculate_temp" = "HOT", "hotspotOpt1"="H3D", 
#                                                           "lud_diagonal"="LUD-K1", "lud_internal"="LUD-K2", "lud_perimeter"="LUD-K3",  
#                                                           "needle_cuda_shared_1"="NDL-K1", "needle_cuda_shared_2"="NDL-K2"))
# 
# Result_RF$Kernels <- factor(Result_RF$Kernels, levels = c("BCK-K1", "BCK-K2",  "GAU-K1", "GAU-K2", "HWL",  "HOT", "H3D", "LUD-K1",
#                                                                   "LUD-K2", "LUD-K3", "NDL-K1", "NDL-K2"))
# 
# 
# Result_RF$GPUs <- factor(Result_RF$GPUs, levels = c("GTX-680", "Tesla-K40",
#                                                        "Tesla-K20",  "Titan", "Quadro", "TitanX", "GTX-970", "GTX-980"))
# 
# 
# View(count(Result_RF, c("threshCorr", "numberFeatures","Kernels", "mape")))
# 
# print(sum(Result_RF$mape[Result_RF$numberFeatures == 5])/
#           length(Result_RF$mse[Result_RF$numberFeatures == 5]))
# print(sum(Result_RF$mape[Result_RF$numberFeatures == 10])/
#           length(Result_RF$mse[Result_RF$numberFeatures == 10]))
# 
# Context1 <- c(1.826,1.652,2.004,1.902,1.909,1.937)
# summary(Context1)
# 
# Context2 <- c(3.14,7.908,2.994,6.561,6.16,4.59)
# summary(Context2)
