
dataTemp <- dataGPUsApps

dataTempDotProd <- dataTemp[dataTemp$CC == 3 & dataTemp$Apps == "dotProd",]
dataTempDotProd$Accuracy <- as.numeric(as.character(dataTempDotProd$Accuracy))
AccuracyDotProdRF <- 1.0128362527
AccuracyDotProdAM <- sum(dataTempDotProd$Accuracy)/length(dataTempDotProd$Accuracy)


dataTempMatMul <- dataTemp[dataTemp$CC == 3 & 
                               dataTemp$Apps == "matMul_gpu_uncoalesced" |
                               dataTemp$Apps == "matMul_gpu" | 
                               dataTemp$Apps == "matMul_gpu_sharedmem_uncoalesced"  |
                               dataTemp$Apps == "matMul_gpu_sharedmem",]

dataTempMatMul$Accuracy <- as.numeric(as.numeric(as.character(dataTempMatMul$Accuracy)))
AccuracyMatMulRF <- 0.9683248799
AccuracyMatMulAM <- sum(dataTempMatMul$Accuracy)/length(dataTempMatMul$Accuracy)


dataTempMatSum <- dataTemp[dataTemp$CC == 3 & dataTemp$Apps == "matrix_sum_normal" |
                               dataTemp$Apps == "matrix_sum_coalesced",]
dataTempMatSum$Accuracy <- as.numeric(as.character(dataTempMatSum$Accuracy))
AccuracyMatSumRF <- 1.0128362527
AccuracyMatSumAM <- sum(dataTempMatSum$Accuracy)/length(dataTempMatSum$Accuracy)


dataTempSSM <- dataTemp[dataTemp$CC == 3 & dataTemp$Apps == c("subSeqMax"),]
dataTempSSM$Accuracy <- as.numeric(as.character(dataTempSSM$Accuracy))
AccuracySSMRF <- 0.9291067931
AccuracySSMAM <- sum(dataTempSSM$Accuracy)/length(dataTempSSM$Accuracy)


dataTempVadd <- dataTemp[dataTemp$CC == 3 & dataTemp$Apps == c("vectorAdd"),]
dataTempVadd$Accuracy <- as.numeric(as.character(dataTempVadd$Accuracy))
AccuracyVaddRF <- 0.8695833396
AccuracyVaddAM <- sum(dataTempSSM$Accuracy)/length(dataTempVadd$Accuracy)

RamForest <-c(AccuracyDotProdRF, AccuracyMatMulRF,AccuracyMatSumRF, AccuracySSMRF, AccuracyVaddF)
AnaModel <- c(AccuracyDotProdAM, AccuracyMatMulAM, AccuracyMatSumAM, AccuracySSMAM, AccuracyVaddAM)

data <- structure(list(MatMul = c(AccuracyMatMulRF, AccuracyMatMulAM),MatSum = c(AccuracyMatSumRF, AccuracyMatSumAM), 
                       DotProd= c(AccuracyDotProdRF, AccuracyDotProdAM), SSM = c(AccuracySSMRF, AccuracySSMAM), 
                       VAdd= c(AccuracyVaddRF,AccuracyVaddAM)), .Names = c("MatMul", "MatAdd", "Dot Product", "SubSeqMax", "VecAdd"), class = "data.frame", row.names = c(NA, -2L))
attach(data)
print(data)

pdf("./images/Barplot-RandomForest-Vs-AnalyticalModel.pdf", height=10, width=16)
par(mar=c(5.1, 6.1, 4.1, 18), xpd=TRUE)
barplot(as.matrix(data),  
        ylab = "Accuracy", main="Random Forest versus Analytical Model Over Kepler Architectures", cex.names=2, cex.axis = 2.25, cex.lab = 2.25, cex.main = 2.25,
        legend = c("Random Forest", "GPU BSP Model"), 
        args.legend = list(x = "topright", cex = 2, inset=c(-0.3,0)), beside=TRUE, col=gray.colors(2))
dev.off()

