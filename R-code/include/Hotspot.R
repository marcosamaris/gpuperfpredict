#     ########################### Hotspot calculate_temp
N_i <- 1024#c(64, 128, 256, 512, 1024)
N_j <- 1024
threadsPerBlock <- 16 * 16
blocksPerGrid <- (as.integer((N_i/(16-4))+1)^2)

numberthreads <- rep(1893376, 256)

NDivision <- 0;
NMultiplication <- 1;
NSum <- 1;
Comp <- 5000;

gmRead <- 2
gmStore <- 1
smRead <- 2
smStore <-1
CommGM <- (gmStore + gmRead - L1 - L2)*gGM + L1*gL1 + L2*gL2;

timeKernel <- numberthreads*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 6]);

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
