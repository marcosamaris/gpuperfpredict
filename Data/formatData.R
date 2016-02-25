dirpath <- "~/Dropbox/Doctorate/Results/2016/svm-gpuperf/data/"

setwd(paste(dirpath, sep=""))

eventsName  <- read.csv(paste("./eventsName.csv",sep=","),header = TRUE)
metricsName  <- read.csv(paste("./metricsName.csv",sep=","),header = TRUE)
tracesName  <- read.csv(paste("./metricsName.csv",sep=","),header = TRUE)

SSM_Metrics  <- as.matrix(read.csv(paste("./Tesla-K40/Subseqmax-metrics.csv",sep=","),header = FALSE,col.names = names(metricsName)))
#Bit_Metrics  <- as.matrix(read.csv(paste("./Tesla-K40/bitonic_sort-metrics.csv",sep=","),header = FALSE,col.names = names(metricsName)))
DotP_Metrics  <- as.matrix(read.csv(paste("./Tesla-K40/dotProd-metrics.csv",sep=","),header = FALSE,col.names = names(metricsName)))
MMGPU_Metrics  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu-metrics.csv",sep=","),header = FALSE,col.names = names(metricsName)))
MMS_Metrics  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu_sharedmem-metrics.csv",sep=","),header = FALSE,col.names = names(metricsName)))
MMSU_Metrics  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu_sharedmem_uncoalesced-metrics.csv",sep=","),header = FALSE,col.names = names(metricsName)))
MMGPUUN_Metrics  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu_uncoalesced-metrics.csv",sep=","),header = FALSE,col.names = names(metricsName)))
QS_Metrics  <- as.matrix(read.csv(paste("./Tesla-K40/quicksort-metrics.csv",sep=","),header = FALSE,col.names = names(metricsName)))
VAdd_Metrics  <- as.matrix(read.csv(paste("./Tesla-K40/vectorAdd-metrics.csv",sep=","),header = FALSE,col.names = names(metricsName)))
MACo_Metrics  <- as.matrix(read.csv(paste("./Tesla-K40/matrix_sum_coalesced-metrics.csv",sep=","),header = FALSE,col.names = names(metricsName)))
MAUn_Metrics  <- as.matrix(read.csv(paste("./Tesla-K40/matrix_sum_normal-metrics.csv",sep=","),header = FALSE,col.names = names(metricsName)))

Metrics <- rbind(SSM_Metrics, DotP_Metrics,  
                 MMGPU_Metrics, MMS_Metrics, MMSU_Metrics, MMGPUUN_Metrics,
                 QS_Metrics, VAdd_Metrics, MACo_Metrics, MAUn_Metrics )

#colnames(Metrics) <-  names(metricsName)

SSM_Events  <- as.matrix(read.csv(paste("./Tesla-K40/Subseqmax-events.csv",sep=","),header = FALSE, col.names = names(eventsName)))
#Bit_Events  <- as.matrix(read.csv(paste("./Tesla-K40/bitonic_sort-events.csv",sep=","),header = FALSE, col.names = names(eventsName)))
DotP_Events  <- as.matrix(read.csv(paste("./Tesla-K40/dotProd-events.csv",sep=","),header = FALSE, col.names = names(eventsName)))
MMGPU_Events  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu-events.csv",sep=","),header = FALSE, col.names = names(eventsName)))
MMS_Events  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu_sharedmem-events.csv",sep=","),header = FALSE, col.names = names(eventsName)))
MMSU_Events  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu_sharedmem_uncoalesced-events.csv",sep=","),header = FALSE, col.names = names(eventsName)))
MMGPUUN_Events  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu_uncoalesced-events.csv",sep=","),header = FALSE, col.names = names(eventsName)))
QS_Events  <- as.matrix(read.csv(paste("./Tesla-K40/quicksort-events.csv",sep=","),header = FALSE, col.names = names(eventsName)))
VAdd_Events  <- as.matrix(read.csv(paste("./Tesla-K40/vectorAdd-events.csv",sep=","),header = FALSE, col.names = names(eventsName)))
MACo_Events  <- as.matrix(read.csv(paste("./Tesla-K40/matrix_sum_coalesced-events.csv",sep=","),header = FALSE, col.names = names(eventsName)))
MAUn_Events  <- as.matrix(read.csv(paste("./Tesla-K40/matrix_sum_normal-events.csv",sep=","),header = FALSE, col.names = names(eventsName)))

Events <- rbind(SSM_Events,  DotP_Events,  
                 MMGPU_Events, MMS_Events, MMSU_Events, MMGPUUN_Events,
                 QS_Events, VAdd_Events, MACo_Events, MAUn_Events )

SSM_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/Subseqmax-kernel-traces.csv",sep=","),header = FALSE))
#Bit_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/bitonic_sort-kernel-traces.csv",sep=","),header = FALSE))
DotP_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/dotProd-kernel-traces.csv",sep=","),header = FALSE))
MMGPU_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu-kernel-traces.csv",sep=","),header = FALSE))
MMS_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu_sharedmem-kernel-traces.csv",sep=","),header = FALSE))
MMSU_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu_sharedmem_uncoalesced-kernel-traces.csv",sep=","),header = FALSE))
MMGPUUN_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu_uncoalesced-kernel-traces.csv",sep=","),header = FALSE))
QS_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/quicksort-kernel-traces.csv",sep=","),header = FALSE))
VAdd_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/vectorAdd-kernel-traces.csv",sep=","),header = FALSE))
MACo_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/matrix_sum_coalesced-kernel-traces.csv",sep=","),header = FALSE))
MAUn_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/matrix_sum_normal-kernel-traces.csv",sep=","),header = FALSE))


SSM_Traces_HtoD  <- as.matrix(read.csv(paste("./Tesla-K40/Subseqmax-HtoD-traces.csv",sep=","),header = FALSE))
#Bit_Traces_HtoD  <- as.matrix(read.csv(paste("./Tesla-K40/bitonic_sort-HtoD-traces.csv",sep=","),header = FALSE))
DotP_Traces_HtoD  <- as.matrix(read.csv(paste("./Tesla-K40/dotProd-HtoD-traces.csv",sep=","),header = FALSE))
MMGPU_Traces_HtoD  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu-HtoD-traces.csv",sep=","),header = FALSE))
MMS_Traces_HtoD  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu_sharedmem-HtoD-traces.csv",sep=","),header = FALSE))
MMSU_Traces_HtoD  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu_sharedmem_uncoalesced-HtoD-traces.csv",sep=","),header = FALSE))
MMGPUUN_Traces_HtoD  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu_uncoalesced-HtoD-traces.csv",sep=","),header = FALSE))
QS_Traces_HtoD  <- as.matrix(read.csv(paste("./Tesla-K40/quicksort-HtoD-traces.csv",sep=","),header = FALSE))
VAdd_Traces_HtoD  <- as.matrix(read.csv(paste("./Tesla-K40/vectorAdd-HtoD-traces.csv",sep=","),header = FALSE))
MACo_Traces_HtoD  <- as.matrix(read.csv(paste("./Tesla-K40/matrix_sum_coalesced-HtoD-traces.csv",sep=","),header = FALSE))
MAUn_Traces_HtoD  <- as.matrix(read.csv(paste("./Tesla-K40/matrix_sum_normal-HtoD-traces.csv",sep=","),header = FALSE))


SSM_Traces_DtoH  <- as.matrix(read.csv(paste("./Tesla-K40/Subseqmax-DtoH-traces.csv",sep=","),header = FALSE))
#Bit_Traces_DtoH  <- as.matrix(read.csv(paste("./Tesla-K40/bitonic_sort-DtoH-traces.csv",sep=","),header = FALSE))
DotP_Traces_DtoH  <- as.matrix(read.csv(paste("./Tesla-K40/dotProd-DtoH-traces.csv",sep=","),header = FALSE))
MMGPU_Traces_DtoH  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu-DtoH-traces.csv",sep=","),header = FALSE))
MMS_Traces_DtoH  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu_sharedmem-DtoH-traces.csv",sep=","),header = FALSE))
MMSU_Traces_DtoH  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu_sharedmem_uncoalesced-DtoH-traces.csv",sep=","),header = FALSE))
MMGPUUN_Traces_DtoH  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu_uncoalesced-DtoH-traces.csv",sep=","),header = FALSE))
QS_Traces_DtoH  <- as.matrix(read.csv(paste("./Tesla-K40/quicksort-DtoH-traces.csv",sep=","),header = FALSE))
VAdd_Traces_DtoH  <- as.matrix(read.csv(paste("./Tesla-K40/vectorAdd-DtoH-traces.csv",sep=","),header = FALSE))
MACo_Traces_DtoH  <- as.matrix(read.csv(paste("./Tesla-K40/matrix_sum_coalesced-DtoH-traces.csv",sep=","),header = FALSE))
MAUn_Traces_DtoH  <- as.matrix(read.csv(paste("./Tesla-K40/matrix_sum_normal-DtoH-traces.csv",sep=","),header = FALSE))


Traces <- rbind(SSM_Traces,  DotP_Traces,  
                MMGPU_Traces, MMS_Traces, MMSU_Traces, MMGPUUN_Traces,
                QS_Traces, VAdd_Traces, MACo_Traces, MAUn_Traces )

png(filename="./SubSeqMax-GPU-Times.png", width=800, height=600)

#par(mar=c(1, 4, 2, 1) + 0.1)
#layout(rbind(1,2), heights=c(15,1))  # put legend on bottom 1/8th of the chart
plot(N[dataN], SubSeqMax_gt630[dataN], type="l",  log="xy", lty = 1, lwd=c(5,5), xaxt="n",
     ylim=c(0.1, max(SubSeqMax_gt630[dataN])), xlim=c(1048576, 268435456),
     col=cbbPalette[1], ylab = " ", cex.axis=2.5, cex.lab=3,cex.main=3.5,
     xlab = " ",  main = paste(" ", sep=""));
points(N[dataN], SubSeqMax_gt630[dataN], col = cbbPalette[1], type = "p", pch=20,cex = 3.5)

