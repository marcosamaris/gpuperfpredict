#         ########################### Hearthwall kernel 5
N <- 100

threadsPerBlock <- 256
blocksPerGrid <- 51

numberthreads <- threadsPerBlock*blocksPerGrid

NMultiplication <- 150000
NFMA <- 50000

Comp <- NMultiplication*50 + NFMA*2
gmRead <- 2
gmStore <- 1
smRead <- 2
smStore <-1

CommGM <- (gmStore + gmRead - L1 - L2)*gGM + L1*gL1 + L2*gL2
CommSM <- (smStore + smRead)*gSM

timeKernel <- numberthreads*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 5]);
# predicted <- timeKernel[-1]
measured <- tempFeatures$duration[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[5]) ]
# par(mfrow=c(1,2))
# plot(measured, ylim=range(min(measured, predicted), max(measured, predicted)), main=N[i])
# points(predicted,col="red")
# boxplot(measured/predicted, main=N[i])
measured <- tempFeatures$duration[tempFeatures$gpu == gpu &
                    tempFeatures$kernels == names(kernelsDict[5]) &  tempFeatures$input.size.1 == 100][-1]

appAllKernel <- rbind(appAllKernel,
                      data.frame(gpu=gpus[gpu,"gpu_name"],
                                 kernels=names(kernelsDict[5]),
                                 measured=measured,
                                 predicted=timeKernel,
                                 accuracy=measured/timeKernel,
                                 mape = mean(abs(timeKernel - measured)/abs(measured))*100))


#