#     ########################### Hotspot_3D hotspotOpt1
# 
N_i <- c(8)
N_j <- c(1000)

N = rep(N_j, N_j/2)
N = rep(N, 3)

threadsPerBlock <- 64 * 4
blocksPerGrid <- 8 * 128

# numberthreads <- threadsPerBlock * blocksPerGrid
numberthreads <- tempFeatures$threadsBlocks[tempFeatures$gpu == gpu &
                                                tempFeatures$kernels == names(kernelsDict[7]) &  
                                                tempFeatures$input.size.1 == N_i & tempFeatures$input.size.2 == N_j ]*
    tempFeatures$gridSize[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[7]) &  
                              tempFeatures$input.size.1 == N_i & tempFeatures$input.size.2 == N_j ]


NDivision <- 0;
NMultiplication <- 1;
NSum <- 1;
Comp <- 500;

CommGM <- ((50 + 8 - L1 - L2)*gGM + L1*gL1 + L2*gL2);
CommSM <- 0

timeKernel <- numberthreads*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 7]);

measured <- tempFeatures$duration[tempFeatures$gpu == gpu &
                                    tempFeatures$kernels == names(kernelsDict[6]) &  
                                    tempFeatures$input.size.1 == N_i & tempFeatures$input.size.2 == N_j]

# par(mfrow=c(1,2))
# plot(timeKernel)
# plot(measured/timeKernel)

appAllKernel <- rbind(appAllKernel,
                      data.frame(gpu=gpus[gpu,"gpu_name"],
                                 kernels=names(kernelsDict[6]),
                                 measured=measured,
                                 predicted=timeKernel,
                                 accuracy=measured/timeKernel,
                                 mape = mean(abs(timeKernel - measured)/abs(measured))*100))
