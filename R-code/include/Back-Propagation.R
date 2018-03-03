##### Back Propagation bpnn_layerforward_CUDA - Kernel 1

N <- seq(8192, 65536, 1024)

tileWidth <- 16
threadsPerBlock <- tileWidth*tileWidth
blocksPerGrid <- as.integer((N +  tileWidth -1)/tileWidth)

numberthreads <- threadsPerBlock*blocksPerGrid

numberMultiplication <- 1
pow2 <- 4
numberSum <- 4

Comp <- ((numberMultiplication * 36 + numberSum * 20 + pow2*72));
gmRead <- 2
gmStore <- 1
smRead <- 5
smStore <-5
CommGM <- (gmStore + gmRead - L1 - L2)*gGM + L1*gL1 + L2*gL2;
CommSM <- (smStore + smRead)*gSM;

timeKernel <-  numberthreads*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 1]);

measured<-tempFeatures$duration[tempFeatures$gpu == gpu &
                                  tempFeatures$kernels == names(kernelsDict[1])] 

appAllKernel <- rbind(appAllKernel,
                      data.frame(gpu=gpus[gpu,"gpu_name"],
                                 kernels=names(kernelsDict[1]),
                                 measured=measured,
                                 predicted=timeKernel,
                                 accuracy=measured/timeKernel,
                                 mape = mean(abs(timeKernel - measured)/abs(measured))*100))
#
#
#

##### Back Propagation bpnn_adjust_weights_cuda - Kernel 2

# numberthreads <- tempFeatures$threads[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[2])];

numberMultiplication <- 1;
numberSum <- 4;
Comp <- ((numberMultiplication * 36 + numberSum * 20));

L1Effect <- 0
L2Effect <- 0

gmRead <- 4
gmStore <- 1
smRead <- 0
smStore <- 0
CommGM <- (gmStore + gmRead - L1 - L2)*gGM + L1*gL1 + L2*gL2;

CommSM <- 0

timeKernel <- numberthreads*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)* lambda[gpu,2]);

# predicted<-timeKernel
# measured<-tempFeatures$duration[tempFeatures$gpu == gpu &
#                           tempFeatures$kernels == names(kernelsDict[3])] # &
#                           # tempFeatures$input.size.1 == N[i]]

#  plot(measured, ylim=range(min(measured, predicted), max(measured, predicted)), main=N[i])
#  points(predicted,col="red")
# }


appAllKernel <- rbind(appAllKernel,
                      data.frame(gpu=gpus[gpu,"gpu_name"],
                                 kernels=names(kernelsDict[2]),
                                 measured=measured,
                                 predicted=timeKernel,
                                 accuracy=measured/timeKernel,
                                 mape = mean(abs(timeKernel - measured)/abs(measured))*100))