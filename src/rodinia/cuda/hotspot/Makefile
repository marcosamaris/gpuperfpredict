include ../../common/make.config
include ../../common/init.config

CC := $(CUDA_DIR)/bin/nvcc

INCLUDE := $(CUDA_DIR)/include

SRC = hotspot.cu

EXE = hotspot

release: $(SRC)
	$(CC) $(devId) $(FLAGSpecial) $(FLAGArch) $(KERNEL_DIM) $(SRC) -o $(EXE) -I$(INCLUDE) -L$(CUDA_LIB_DIR) 

enum: $(SRC)
	$(CC) $(devId) $(FLAGSpecial) $(FLAGArch) $(KERNEL_DIM) -deviceemu $(SRC) -o $(EXE) -I$(INCLUDE) -L$(CUDA_LIB_DIR) 

debug: $(SRC)
	$(CC) $(devId) $(FLAGSpecial) $(FLAGArch) $(KERNEL_DIM) -g $(SRC) -o $(EXE) -I$(INCLUDE) -L$(CUDA_LIB_DIR) 

debugenum: $(SRC)
	$(CC) $(devId) $(FLAGSpecial) $(FLAGArch) $(KERNEL_DIM) -g -deviceemu $(SRC) -o $(EXE) -I$(INCLUDE) -L$(CUDA_LIB_DIR) 

clean: $(SRC)
	rm -f $(EXE) $(EXE).linkinfo result.txt
