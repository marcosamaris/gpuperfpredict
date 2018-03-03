N_i <- seq(256, 4096, 256)
N_j <- 1:10

threadsPerBlock <- 16
blocksPerGrid <- NULL
for (i in 1:length(N_i)){
  blocksPerGrid <- c(blocksPerGrid, seq(1,N_i[i]/16))
}

numberthreads <- threadsPerBlock * blocksPerGrid

nnumberMultiplication <- 6;
numberDivision <- 0;
numberSum <- 9;
ComputationKernel <- (numberMultiplication * 24 + numberSum * 10 + numberDivision * 36 );

L1Effect <- 0
L2Effect <- 0

CommGM <- (1)*latencyGlobalMemory + L1Effect*latencyL1 + L2Effect*latencyL2;
CommSM <- (N)*latencySharedMemory;

timeKernel <- numberthreads*(ComputationKernel + CommGM + CommSM)/((flopsTheoreticalPeak[2,]*10^6)* lambda[j,12]);

needle_cuda_shared_1 <- timeKernel/subset(appList$nw[grep("_1", appList$nw$Name),])["Duration"]

######################### Needleman-Wunsch needle_cuda_shared_2

N_i <- seq(256, 4096, 256)
N_j <- 1:10

threadsPerBlock <- 16
blocksPerGrid <- NULL
for (i in 1:length(N_i)){
  blocksPerGrid <- c(blocksPerGrid, seq(N_i[i]/16-1 , 1))
}

numberthreads <- threadsPerBlock * blocksPerGrid

nnumberMultiplication <- 6;
numberDivision <- 0;
numberSum <- 9;
ComputationKernel <- (numberMultiplication * 24 + numberSum * 10 + numberDivision * 36 );

L1Effect <- 0
L2Effect <- 0

CommGM <- (1)*latencyGlobalMemory + L1Effect*latencyL1 + L2Effect*latencyL2;
CommSM <- (1)*latencySharedMemory;

timeKernel <- numberthreads*(ComputationKernel + CommGM + CommSM)/((flopsTheoreticalPeak[2,]*10^6)* lambda[j,13]);

needle_cuda_shared_2 <- timeKernel/subset( appList$nw[grep("_2", appList$nw$Name),])["Duration"]