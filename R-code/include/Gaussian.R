#     ########################### Gaussian Fan1  - Kernel 3

N <- 4096
# N = 256

threadsBlocks <- 8
gridSize <- 512
numberthreads <- threadsBlocks*gridSize

numberthreads <- seq(N-1, 1)
  
NDivision <- 0
NMultiplication <- 1
NSum <- 0
Comp <- (NDivision * 24 + NMultiplication*36 + NSum * 20)

L1Effect <- 0
L2Effect <- 0

gmRead <- 1
gmStore <- 1
smRead <- 0
smStore <-0
CommGM <- (gmStore + gmRead - L1 - L2)*gGM + L1*gL1 + L2*gL2;
CommSM <- 0

timeKernel <- numberthreads*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 3])
measured <- tempFeatures$duration[tempFeatures$gpu == gpu &
                                    tempFeatures$kernels == names(kernelsDict[3])  &
                                    tempFeatures$input.size.1 == N]
varLimite <- N - 1024
# 
# par(mfrow=c(1,2))
# plot(x = numberthreads[1:varLimite],y = timeKernel[1:varLimite])
# lines(x = numberthreads[1:varLimite],y = measured[1:varLimite])
# 
# plot(x = numberthreads[1:varLimite],y = measured[1:varLimite]/timeKernel[1:varLimite])

appAllKernel <- rbind(appAllKernel,
                      data.frame(gpu=gpus[gpu,"gpu_name"],
                                 kernels=names(kernelsDict[3]),
                                 measured=measured[1:varLimite],
                                 predicted=timeKernel[1:varLimite],
                                 accuracy=measured[1:varLimite]/timeKernel[1:varLimite],
                                 mape = mean(abs(timeKernel[1:varLimite] - measured[1:varLimite])/abs(measured[1:varLimite]))*100))

########################### Gaussian Fan2 - Kernel 4

N <- 4096
tileSize = 4
threadsPerBlock <- tileSize*tileSize
blocksPerGrid <- ceiling((N/tileSize))^2

#gridsizes <- ceiling((N/threadsPerBlock) + (!(N %% threadsPerBlock)));
numberthreads <- threadsPerBlock * blocksPerGrid

numberthreads <- seq(N-1, 1)*seq(N-1, 1)

NDivision <- 0;
NMultiplication <- 1
NSum <- 1;
Comp <- (NDivision * 24 + NMultiplication*24 + NSum * 20);

gmRead <- 3
gmStore <- 2
smRead <- 0
smStore <-0
CommGM <- (gmStore + gmRead - L1 - L2)*gGM + L1*gL1 + L2*gL2;
CommSM <- 0

timeKernel <- numberthreads*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 4]);
measured <- tempFeatures$duration[tempFeatures$gpu == gpu &
                                  tempFeatures$kernels == names(kernelsDict[4])  &
                                  tempFeatures$input.size.1 == N]
varLimite <- N - 1536

appAllKernel <- rbind(appAllKernel,
                      data.frame(gpu=gpus[gpu,"gpu_name"],
                                 kernels=names(kernelsDict[4]),
                                 measured=measured[1:varLimite],
                                 predicted=timeKernel[1:varLimite],
                                 accuracy=measured[1:varLimite]/timeKernel[1:varLimite],
                                 mape = mean(abs(timeKernel[1:varLimite] - measured[1:varLimite])/abs(measured[1:varLimite]))*100))
# 
#

