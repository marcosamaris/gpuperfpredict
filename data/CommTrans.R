dirpath <- "~/Dropbox/Doctorate/Results/2016/svm-gpuperf/data/"

setwd(paste(dirpath, sep=""))
cbbPalette <- gray(1:6/ 8)#c("red", "blue", "darkgray", "orange","black","brown", "lightblue","violet")
tracesName  <- read.csv(paste("./tracesName.csv",sep=","),header = TRUE)

SSM_Traces_HtoD_TeslaK40  <- as.matrix(read.csv(paste("./Tesla-K40/vectorTrans-HtoD-traces.csv",sep=","),header = FALSE, col.names = names(tracesName)))
SSM_Traces_HtoD_980  <- as.matrix(read.csv(paste("./GeForce-980/vectorTrans-HtoD-traces.csv",sep=","),header = FALSE, col.names = names(tracesName)))
SSM_Traces_HtoD_750  <- as.matrix(read.csv(paste("./GeForce-750/vectorTrans-HtoD-traces.csv",sep=","),header = FALSE, col.names = names(tracesName)))

SSM_Traces_DtoH_TeslaK40  <- as.matrix(read.csv(paste("./Tesla-K40/vectorTrans-DtoH-traces.csv",sep=","),header = FALSE), col.names = names(tracesName))
SSM_Traces_DtoH_980  <- as.matrix(read.csv(paste("./GeForce-980/vectorTrans-DtoH-traces.csv",sep=","),header = FALSE, col.names = names(tracesName)))
SSM_Traces_DtoH_750  <- as.matrix(read.csv(paste("./GeForce-750/vectorTrans-DtoH-traces.csv",sep=","),header = FALSE), col.names = names(tracesName))


dfHtoD <- data.frame(SSM_Traces_HtoD_TeslaK40, SSM_Traces_HtoD_980, SSM_Traces_HtoD_750)

Nn <- 17:28;
N <- 2^Nn;

png(filename="../images/Trans-Times-HtoD.png", width=800, height=600)
par(mar=c(5, 10, 4, 1) + 0.1)
#layout(rbind(1,2), heights=c(15,1))  # put legend on bottom 1/8th of the chart
plot(N, SSM_Traces_HtoD_980[1:12,2], type="l",  log="xy", lty = 1, lwd=c(5,5), xaxt="n", yaxt="n",
     col=cbbPalette[1], ylab = " ", cex.axis=1, cex.lab=3,cex.main=3.5,
     xlab = "Size MBytes",  main = paste("Data Transference HtoD ", sep=""));
points(N, SSM_Traces_HtoD_980[1:12,2], col = cbbPalette[1], type = "p", pch=20,cex = 3.5)

lines(N, SSM_Traces_HtoD_750[1:12,2], col = cbbPalette[2], lty = 2,lwd=c(7.5,7.5));
points(N, SSM_Traces_HtoD_750[1:12,2], col = cbbPalette[2], pch=22,cex = 3.5);

lines(N, SSM_Traces_HtoD_TeslaK40[1:12,2], col = cbbPalette[3], lty = 3,lwd=c(7.5,7.5));
points(N, SSM_Traces_HtoD_TeslaK40[1:12,2], col = cbbPalette[3], pch=21,cex = 3.5);

axis(1, at = c(N), labels = paste('2^',log2(c(N)),sep="") , cex.axis=1)
axis(2, at = SSM_Traces_HtoD_980[1:12,2], labels = SSM_Traces_HtoD_980[1:12,2] , cex.axis=1, las=1)

dev.off()


png(filename="../images/Trans-Times-DtoH.png", width=800, height=600)
par(mar=c(5, 10, 4, 1) + 0.1)
#layout(rbind(1,2), heights=c(15,1))  # put legend on bottom 1/8th of the chart
plot(N, SSM_Traces_DtoH_750[1:12,2], type="l",  log="xy", lty = 1, lwd=c(5,5), xaxt="n", yaxt="n",
     col=cbbPalette[1], ylab = " ", cex.axis=1, cex.lab=3,cex.main=3.5,
     xlab = "Size MBytes",  main = paste("Data Transference DtoH ", sep=""));
points(N, SSM_Traces_DtoH_750[1:12,2], col = cbbPalette[1], type = "p", pch=20,cex = 3.5)

lines(N, SSM_Traces_DtoH_980[1:12,2], col = cbbPalette[2], lty = 2,lwd=c(7.5,7.5));
points(N, SSM_Traces_DtoH_980[1:12,2], col = cbbPalette[2], pch=22,cex = 3.5);

lines(N, SSM_Traces_DtoH_TeslaK40[1:12,2], col = cbbPalette[3], lty = 3,lwd=c(7.5,7.5));
points(N, SSM_Traces_DtoH_TeslaK40[1:12,2], col = cbbPalette[3], pch=21,cex = 3.5);

axis(1, at = c(N), labels = paste('2^',log2(c(N)),sep="") , cex.axis=1)
axis(2, at = SSM_Traces_DtoH_980[1:12,2], labels = SSM_Traces_DtoH_980[1:12,2] , cex.axis=1, las=1)

dev.off()
