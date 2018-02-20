include ../../common/make.config
include ../../common/init.config

CC := $(CUDA_DIR)/bin/nvcc $(devId) $(FLAGSpecial) $(FLAGArch)

INCLUDE := $(CUDA_DIR)/include

SRC = needle.cu

EXE = needle

release: $(SRC)
	$(CC) ${KERNEL_DIM} $(SRC) -o $(EXE) -I$(INCLUDE) -L$(CUDA_LIB_DIR) 

enum: $(SRC)
	$(CC) ${KERNEL_DIM} -deviceemu $(SRC) -o $(EXE) -I$(INCLUDE) -L$(CUDA_LIB_DIR) 

debug: $(SRC)
	$(CC) ${KERNEL_DIM} -g $(SRC) -o $(EXE) -I$(INCLUDE) -L$(CUDA_LIB_DIR) 

debugenum: $(SRC)
	$(CC) ${KERNEL_DIM} -g -deviceemu $(SRC) -o $(EXE) -I$(INCLUDE) -L$(CUDA_LIB_DIR) 

clean: $(SRC)
	rm -f $(EXE) $(EXE).linkinfo result.txt
