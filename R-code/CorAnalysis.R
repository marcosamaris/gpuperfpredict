library(e1071)
library(ggplot2)
library(Hmisc)

dirpath <- "~/Doctorate/svm-gpuperf/"
setwd(paste(dirpath, sep=""))

gpus <- read.table("./R-code/deviceInfo.csv", sep=",", header=T)
NoGPU <- dim(gpus)[1]

apps <- c("matMul_gpu_uncoalesced","matMul_gpu", "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem",
          "matrix_sum_normal", "matrix_sum_coalesced", 
          "dotProd", "vectorAdd",  "subSeqMax")

Parameters_3x <- c("GpuName","GpuId", "L2", "Bus", "Memoryclock", "AppName", "AppId",  "Input.Size","Duration","Issued.IPC",	"Instructions.per.warp",	"Issue.Slot.Utilization",
                   "Shared.Memory.Load.Transactions.Per.Request",	"Shared.Memory.Store.Transactions.Per.Request",
                   "Global.Load.Transactions.Per.Request",	"Global.Store.Transactions.Per.Request",
                   "Shared.Load.Transactions",	"Shared.Store.Transactions", "Global.Load.Transactions",	"Global.Store.Transactions",
                   "Device.Memory.Read.Transactions",	"Device.Memory.Write.Transactions", "L2.Read.Transactions",	"L2.Write.Transactions",
                   "Issued.Control.Flow.Instructions",	"Executed.Control.Flow.Instructions",	"Issued.Load.Store.Instructions",	"Executed.Load.Store.Instructions",
                   "Floating.Point.Operations.Single.Precision.", "Floating.Point.Operations.Single.Precision.FMA.","Instructions.Executed",	"Instructions.Issued",
                   "Issue.Slots","FP.Instructions.Single.", "Control.Flow.Instructions", "Misc.Instructions", "L2.Read.Transactions..L1.read.requests.", "L2.Write.Transactions..L1.write.requests.",
                   "ECC.Transactions", "Eligible.Warps.Per.Active.Cycle", "FLOP.Efficiency.Peak.Single.","fb_subp0_read_sectors",	"fb_subp1_read_sectors",	"fb_subp0_write_sectors",	"fb_subp1_write_sectors", "warps_launched",	
                   "threads_launched",	"inst_executed",	"inst_issued1",	"inst_issued2","gld_inst_32bit", "gst_inst_32bit", "gld_request",	"gst_request", "Grid.X", "Block.X")

Parameters_5x <- c("GpuName","GpuId", "L2", "Bus", "Memoryclock", "AppName", "AppId", "Input.Size", "Duration","Issued.IPC",	"Instructions.per.warp",	"Issue.Slot.Utilization",
                   "Shared.Memory.Load.Transactions.Per.Request",	"Shared.Memory.Store.Transactions.Per.Request",
                   "Global.Load.Transactions.Per.Request",	"Global.Store.Transactions.Per.Request",
                   "Shared.Load.Transactions",	"Shared.Store.Transactions", "Global.Load.Transactions",	"Global.Store.Transactions",
                   "Device.Memory.Read.Transactions",	"Device.Memory.Write.Transactions", "L2.Read.Transactions",	"L2.Write.Transactions",
                   "Global.Hit.Rate",
                   "Issued.Control.Flow.Instructions",	"Executed.Control.Flow.Instructions",	"Issued.Load.Store.Instructions",	"Executed.Load.Store.Instructions",
                   "Floating.Point.Operations.Single.Precision.", "Floating.Point.Operations.Single.Precision.FMA.","Instructions.Executed",	"Instructions.Issued",
                   "Issue.Slots","FP.Instructions.Single.", "Control.Flow.Instructions", "Misc.Instructions",
                   "Eligible.Warps.Per.Active.Cycle", "FLOP.Efficiency.Peak.Single.","fb_subp0_read_sectors",	"fb_subp1_read_sectors",	"fb_subp0_write_sectors",	"fb_subp1_write_sectors", "warps_launched",	
                   "inst_executed",	"inst_issued1",	"inst_issued2","gld_inst_32bit", "gst_inst_32bit", "Grid.X", "Block.X")

# 
# Parameters_5x <- c("GpuName","GpuId", "AppName", "AppId", "Input.Size", "Duration",
#                    "Global.Load.Transactions",	"Global.Store.Transactions",
#                    "Device.Memory.Read.Transactions",	"Device.Memory.Write.Transactions", "L2.Read.Transactions",
#                    "Global.Hit.Rate",
#                    "Instructions.Issued",
#                    "Control.Flow.Instructions", 
#                    "warps_launched",
#                    "inst_issued1",	"Grid.X", "Block.X")
# 
# Parameters_3x <- c("GpuName","GpuId", "AppName", "AppId",  "Input.Size","Duration",
#                    "Global.Load.Transactions",	"Global.Store.Transactions",
#                    "Device.Memory.Read.Transactions",	"Device.Memory.Write.Transactions", "L2.Read.Transactions",	
#                    "Instructions.Issued",
#                    "Control.Flow.Instructions", "L2.Read.Transactions..L1.read.requests.",
#                    "inst_executed",	"Grid.X","Block.X")

# Those parameters are always 0 in CC 3.5  and 5.2
# Local.Memory.Load.Transactions.Per.Request
# Local.Memory.Store.Transactions.Per.Request
# Local.Load.Transactions
# Local.Store.Transactions
# 
# Those parameters are not in CC 5.2 or they are always 0
#     L2.Read.Transactions..L1.read.requests.
#     L2.Write.Transactions..L1.write.requests.
#     ECC.Transactions
#     threads_launched
#     gld_request
#     gst_request


DataAppGPU30 <- read.csv(file = paste("./R-code/Datasets/AppGPU30.csv", sep = ""))
DataAppGPU35 <- read.csv(file = paste("./R-code/Datasets/AppGPU35.csv", sep = ""))
DataAppGPU50 <- read.csv(file = paste("./R-code/Datasets/AppGPU50.csv", sep = ""))
DataAppGPU52 <- read.csv(file = paste("./R-code/Datasets/AppGPU52.csv", sep = ""))

Data <- rbind(DataAppGPU30[Parameters_3x], DataAppGPU35[Parameters_3x])
Data <- rbind(DataAppGPU50[Parameters_5x], DataAppGPU52[Parameters_5x])

Data <- Data[complete.cases(Data),]

Data$AppName <- NULL
Data$GpuName <- NULL



scatterplotMatrix(Data)

for(i in 1:51){
    png(paste("images/scarplot-5.X/",i, "-",names(Data[i]),".png", sep=""),width=1200, height=1200)
    par(mfrow=c(3,3),cex.lab=1.25, cex=1)
    for (j in 1:9) {
      DataT <- subset(Data, AppId == j )
      plot(DataT$Duration, DataT[,i], main = apps[j], xlab = "Seconds", ylab=names(DataT[i]), cex=1.5)
    }
    mtext(names(DataT[i]), outer = TRUE, cex = 2.5)
    dev.off()
}


valorCor <- 1 - cor(Data)
valorCorDist <- as.dist(valorCor)
hc<-hclust(valorCorDist)
summary(hc)
plot(hc)

panel.cor <- function(x, y, digits=2, prefix="", cex.cor, ...)
{
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  r <- abs(cor(x, y))
  txt <- format(c(r, 0.123456789), digits=digits)[1]
  txt <- paste(prefix, txt, sep="")
  if(missing(cex.cor)) cex.cor <- 0.8/strwidth(txt)
  text(0.5, 0.5, txt, cex = cex.cor * r)
}

T <- 40
pairs(Data[1:20],lower.panel=panel.cor, upper.panel=panel.smooth)

mosthighlycorrelated <- function(mydataframe,numtoreport)
{
  # find the correlations
  cormatrix <- cor(mydataframe)
  # set the correlations on the diagonal or lower triangle to zero,
  # so they will not be reported as the highest ones:
  diag(cormatrix) <- 0
  cormatrix[lower.tri(cormatrix)] <- 0
  # flatten the matrix into a dataframe for easy sorting
  fm <- as.data.frame(as.table(cormatrix))
  # assign human-friendly names
  names(fm) <- c("First.Variable", "Second.Variable","Correlation")
  # sort and print the top n correlations
  head(fm[order(abs(fm$Correlation),decreasing=T),],n=numtoreport)
}

a<-mosthighlycorrelated(Data[1:49], 409)
dim(Data)
