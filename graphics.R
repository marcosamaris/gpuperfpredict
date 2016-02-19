dirpath <- "~/Dropbox/Doctorate/Results/2016/svm-gpuperf/experiments/"

setwd(paste(dirpath, sep=""))

eventsName  <- read.csv(paste("./eventsName.csv",sep=","),header = TRUE)
metricsName  <- read.csv(paste("./metricsName.csv",sep=","),header = TRUE)

SSM_Metrics  <- as.matrix(read.csv(paste("./Tesla-K40/Subseqmax-metrics.csv",sep=","),header = FALSE,col.names = names(metricsName)))
Bit_Metrics  <- as.matrix(read.csv(paste("./Tesla-K40/bitonic_sort-metrics.csv",sep=","),header = FALSE,col.names = names(metricsName)))
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

colnames(Metrics) <-  names(metricsName)

SSM_Events  <- as.matrix(read.csv(paste("./Tesla-K40/Subseqmax-events.csv",sep=","),header = FALSE, col.names = names(eventsName)))
Bit_Events  <- as.matrix(read.csv(paste("./Tesla-K40/bitonic_sort-events.csv",sep=","),header = FALSE, col.names = names(eventsName)))
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

colnames(Events) <-  names(eventsName)



SSM_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/Subseqmax-traces.csv",sep=","),header = FALSE))
Bit_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/bitonic_sort-traces.csv",sep=","),header = FALSE))
DotP_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/dotProd-traces.csv",sep=","),header = FALSE))
MMGPU_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu-traces.csv",sep=","),header = FALSE))
MMS_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu_sharedmem-traces.csv",sep=","),header = FALSE))
MMSU_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu_sharedmem_uncoalesced-traces.csv",sep=","),header = FALSE))
MMGPUUN_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/matMul_gpu_uncoalesced-traces.csv",sep=","),header = FALSE))
QS_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/quicksort-traces.csv",sep=","),header = FALSE))
VAdd_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/vectorAdd-traces.csv",sep=","),header = FALSE))
MACo_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/matrix_sum_coalesced-traces.csv",sep=","),header = FALSE))
MAUn_Traces  <- as.matrix(read.csv(paste("./Tesla-K40/matrix_sum_normal-traces.csv",sep=","),header = FALSE))

dimension <-dim(SSM_Traces)
timeK <- as.array()
k <- 1
for (i in 1:dimension[1]){
  
  if ((i %% 4) == 0){
    timeK[k] <- SSM_Traces[i-1,2]
    k = k + 1
  }
}
