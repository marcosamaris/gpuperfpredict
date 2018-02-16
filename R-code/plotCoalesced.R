library(ggpubr)
library(gridExtra)
library(ggplot2)

MAU_970 <- read.csv("/home/marcos/GIT/BSyncGPGPU/datasets/NCA/matMul_gpu_uncoalesced-GTX-970.csv")
MAC_970 <- read.csv("/home/marcos/GIT/BSyncGPGPU/datasets/NCA/matMul_gpu-GTX-970.csv")

MAU_970 <- MAU_970[MAU_970$Block.X == 8,]
MAC_970 <- MAC_970[MAC_970$Block.X == 8,]

MAU_970$Kernel <- "MMGU"
MAC_970$Kernel <- "MMGC"

df_970 <- rbind(MAU_970, MAC_970)


p1 <- ggplot(data=df_970, aes(x=Input.Size, y=Duration, group=Kernel,col=Kernel)) +
    geom_line(size=1.5) +   geom_point(aes(shape=Kernel), size=3) + theme_bw()+
    scale_colour_grey() +
    scale_fill_grey()+
    ylab(expression(paste("Time log(s)", sep = "" ))) + scale_y_log10()+
    theme(plot.title = element_text(family = "Times", face="bold", size=40)) +
    theme(axis.title = element_text(family = "Times", face="bold", size=20)) +
    theme(axis.text  = element_text(family = "Times", face="bold", size=15, colour = "Black")) +
    theme(legend.title  = element_text(family = "Times", face="bold", size=0)) +
    theme(legend.text  = element_text(family = "Times", face="bold", size=15)) +
    theme(legend.direction = "horizontal",
          legend.position = "bottom",
          legend.key=element_rect(size=0),
          legend.key.size = unit(3, "lines")) +
    guides(col = guide_legend(nrow = 2))

MAU_970 <- read.csv("/home/marcos/GIT/BSyncGPGPU/datasets/NCA/matrix_sum_normal-GTX-970.csv")
MAC_970 <- read.csv("/home/marcos/GIT/BSyncGPGPU/datasets/NCA/matrix_sum_coalesced-GTX-970.csv")

MAU_970 <- na.omit(MAU_970)
MAC_970 <- na.omit(MAC_970)

MAC_970$Input.Size

MAU_970 <- MAU_970[MAU_970$Block.X == 8,]
MAC_970 <- MAC_970[MAC_970$Block.X == 8,]

MAU_970$Kernel <- "MAU"
MAC_970$Kernel <- "MAC"

df_970 <- rbind(MAU_970, MAC_970)


p2 <- ggplot(data=df_970, aes(x=Input.Size, y=Duration, group=Kernel,col=Kernel)) +
    geom_line(size=1.5) +   geom_point(aes(shape=Kernel), size=3) + theme_bw()+ 
    scale_colour_grey() +
    scale_fill_grey()+
    ylab(expression(paste("Time log(s)", sep = "" ))) +scale_y_log10()+
    theme(plot.title = element_text(family = "Times", face="bold", size=40)) +
    theme(axis.title = element_text(family = "Times", face="bold", size=20)) +
    theme(axis.text  = element_text(family = "Times", face="bold", size=15, colour = "Black")) +
    theme(legend.title  = element_text(family = "Times", face="bold", size=0)) +
    theme(legend.text  = element_text(family = "Times", face="bold", size=15)) +
    theme(legend.direction = "horizontal",
          legend.position = "bottom",
          legend.key=element_rect(size=0),
          legend.key.size = unit(3, "lines")) +
    guides(col = guide_legend(nrow = 2))

df <- data.frame(Kernels = c("MMGU","MMGC"), Global.Store.Transactions.Per.Request = c(10, 6))
p3 <- ggplot(df, aes(Kernels, Global.Store.Transactions.Per.Request, col = c("MMGU","MMGC"), fill=c("MMGU","MMGC"))) +
    geom_col() + theme_bw() +
    scale_colour_grey() +
    scale_fill_grey()+
    ylab(expression(paste("GM.Load.Trans.Per.Request", sep = "" ))) +
    theme(plot.title = element_text(family = "Times", face="bold", size=40)) +
    theme(axis.title = element_text(family = "Times", face="bold", size=20)) +
    theme(axis.text  = element_text(family = "Times", face="bold", size=15, colour = "Black")) +
    theme(legend.title  = element_text(family = "Times", face="bold", size=0)) +
    theme(legend.text  = element_text(family = "Times", face="bold", size=15)) +
    theme(legend.direction = "horizontal",
          legend.position = "bottom") +
    guides(col = guide_legend(nrow = 1))

df <- data.frame(Kernels = c("MAU","MAC"), Global.Store.Transactions.Per.Request = c(16, 8))
p4 <- ggplot(df, aes(Kernels, Global.Store.Transactions.Per.Request, col = c("MAU","MAC"), 
                     fill=c("MAU","MAC"))) +
    geom_col() + theme_bw() +
    scale_colour_grey() +
    scale_fill_grey()+
    ylab(expression(paste("GM.Load.Trans.Per.Request", sep = "" ))) +
    theme(plot.title = element_text(family = "Times", face="bold", size=40)) +
    theme(axis.title = element_text(family = "Times", face="bold", size=20)) +
    theme(axis.text  = element_text(family = "Times", face="bold", size=15, colour = "Black")) +
    theme(legend.title  = element_text(family = "Times", face="bold", size=0)) +
    theme(legend.text  = element_text(family = "Times", face="bold", size=15)) +
    theme(legend.direction = "horizontal",
          legend.position = "bottom") +
    guides(col = guide_legend(nrow = 1))

pdf('/home/marcos/GIT/MLvsAMgpuperf/images/plotCoalesced.pdf', width = 12, height = 5)
ggarrange(p1, p3, p2, p4, nrow=1, ncol=4, labels=c(LETTERS[1:4]))
# multiplot(p1, p2, p3, p4, p5, p6,  cols=3)
dev.off()

