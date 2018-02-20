include common/make.config

RODINIA_BASE_DIR := $(shell pwd)

CUDA_BIN_DIR := $(RODINIA_BASE_DIR)/bin/linux/cuda

CUDA_DIRS := backprop gaussian heartwall hotspot hotspot3D lavaMD lud nw pathfinder 

all: 
	cd cuda/backprop;		make;	cp backprop $(CUDA_BIN_DIR)
	cd cuda/gaussian;		make;	cp gaussian $(CUDA_BIN_DIR)
	cd cuda/heartwall;  		make;	cp heartwall $(CUDA_BIN_DIR)
	cd cuda/hotspot; 		make;	cp hotspot $(CUDA_BIN_DIR)
	cd cuda/hotspot3D; 		make;	cp 3D $(CUDA_BIN_DIR)
	cd cuda/lavaMD;			make;	cp lavaMD $(CUDA_BIN_DIR)
	cd cuda/lud; 			make;	cp lud_cuda $(CUDA_BIN_DIR)
	cd cuda/nw; 			make;	cp needle $(CUDA_BIN_DIR)
	#cd cuda/pathfinder;		make;	cp pathfinder $(CUDA_BIN_DIR)

clean:
	cd $(CUDA_BIN_DIR); rm -f *
	for dir in $(CUDA_DIRS) ; do cd cuda/$$dir ; make clean ; cd ../.. ; done
	

