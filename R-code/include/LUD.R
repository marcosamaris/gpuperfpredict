#     ########################### LU decomposition - lud_diagonal

    N <- seq(256, 8192, 256)
    N_diagonal <- rep(N, N/16)

    threadsPerBlock <- 16
    blocksPerGrid <- 1

    numberthreads <- threadsPerBlock * blocksPerGrid
    numberthreads <- tempFeatures$threads[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[9])];

    NDivision <- 0;
    NMultiplication <- 1;
    NSum <- 1;
    Comp <- 5000;

    CommGM <- ((10 - L1 - L2)*gGM + L1*gL1 + L2*gL2);
    CommSM <- 100;

    timeKernel <- numberthreads*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 9]);

    predicted <- timeKernel
    measured <- tempFeatures$duration[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[9])]
    # summary(measured/predicted)
    # length(numberthreads)
    # length(measured)

    # par(mfrow=c(1,2))
    # plot(measured, ylim=range(min(measured, predicted), max(measured, predicted)))
    # points(predicted,col="red")
    # boxplot(measured/predicted)

    appAllKernel <- rbind(appAllKernel,
                          data.frame(measured=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[9])],
                                     predicted=timeKernel,
                                     accuracy=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[9])]/timeKernel,
                                     kernels=names(kernelsDict[9]),
                                     gpu=gpus[gpu,"gpu_name"],
                                     modeling="modeling"))

#     ######################## LUD lud_perimeter


    N_perimeter <- rep(N, N/16 -1)

    threadsPerBlock <- 16
    blocksPerGrid <- 1

    numberthreads <- threadsPerBlock * blocksPerGrid
    numberthreads <- tempFeatures$threads[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[10])];

    NDivision <- 0;
    NMultiplication <- 1;
    NSum <- 1;
    Comp <- 5000;

    CommGM <- ((10 - L1 - L2)*gGM + L1*gL1 + L2*gL2);
    CommSM <- 100;

    timeKernel <- numberthreads*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 10]);

    predicted <- timeKernel
    measured <- tempFeatures$duration[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[10])]
    # summary(measured/predicted)
    # length(numberthreads)
    # length(measured)


    # par(mfrow=c(1,2))
    # plot(measured, ylim=range(min(measured, predicted), max(measured, predicted)))
    # points(predicted,col="red")
    # boxplot(measured/predicted)

    appAllKernel <- rbind(appAllKernel,
                          data.frame(measured=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[10])],
                                     predicted=timeKernel,
                                     accuracy=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[10])]/timeKernel,
                                     kernels=names(kernelsDict[10]),
                                     gpu=gpus[gpu,"gpu_name"],
                                     modeling="modeling"))
#
#     ############################ LUD lud_internal
    N_perimeter <- rep(N, N/16 -1)

    threadsPerBlock <- 16
    blocksPerGrid <- 1

    numberthreads <- threadsPerBlock * blocksPerGrid
    numberthreads <- tempFeatures$threads[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[11])];

    NDivision <- 0;
    NMultiplication <- 1;
    NSum <- 1;
    Comp <- 5000;

    CommGM <- ((10 - L1 - L2)*gGM + L1*gL1 + L2*gL2);
    CommSM <- 100;

    timeKernel <- numberthreads*(Comp + CommGM + CommSM)/((FlopsTh[gpu,]*10^6)*lambda[gpu, 11]);

    predicted <- timeKernel
    measured <- tempFeatures$duration[tempFeatures$gpu == gpu & tempFeatures$kernels == names(kernelsDict[11])]
    # summary(measured/predicted)
    # length(numberthreads)
    # length(measured)


    # par(mfrow=c(1,2))
    # plot(measured, ylim=range(min(measured, predicted), max(measured, predicted)))
    # points(predicted,col="red")
    # boxplot(measured/predicted)

    appAllKernel <- rbind(appAllKernel,
                          data.frame(measured=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[11])],
                                     predicted=timeKernel,
                                     accuracy=tempFeatures$duration[tempFeatures$gpu == gpu &
                                                                        tempFeatures$kernels == names(kernelsDict[11])]/timeKernel,
                                     kernels=names(kernelsDict[11]),
                                     gpu=gpus[gpu,"gpu_name"],
                                     modeling="modeling"))
#
#
