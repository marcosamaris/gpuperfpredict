all:  matMul_gpu_uncoalesced matMul_gpu matMul_gpu_sharedmem_uncoalesced matMul_gpu_sharedmem

include ../common/Makefile.common

matMul_gpu_uncoalesced.o: matMul_gpu_uncoalesced.cu
		$(CC) $(CFLAGS) -c matMul_gpu_uncoalesced.cu

matMul_gpu_uncoalesced: matMul_gpu_uncoalesced.o
		$(CC) $(CFLAGS) matMul_gpu_uncoalesced.o -o matMul_gpu_uncoalesced

matMul_gpu.o: matMul_gpu.cu
		$(CC) $(CFLAGS) -c matMul_gpu.cu

matMul_gpu: matMul_gpu.o 
		$(CC) $(CFLAGS) matMul_gpu.o -o matMul_gpu

matMul_gpu_sharedmem_uncoalesced.o: matMul_gpu_sharedmem_uncoalesced.cu
		$(CC) $(CFLAGS) -c matMul_gpu_sharedmem_uncoalesced.cu

matMul_gpu_sharedmem_uncoalesced: matMul_gpu_sharedmem_uncoalesced.o
		$(CC) $(CFLAGS) matMul_gpu_sharedmem_uncoalesced.o -o matMul_gpu_sharedmem_uncoalesced

matMul_gpu_sharedmem.o: matMul_gpu_sharedmem.cu
		$(CC) $(CFLAGS) -c matMul_gpu_sharedmem.cu

matMul_gpu_sharedmem: matMul_gpu_sharedmem.o
		$(CC) $(CFLAGS) matMul_gpu_sharedmem.o -o matMul_gpu_sharedmem

tests: matMul_gpu_uncoalesced matMul_gpu matMul_gpu_sharedmem_uncoalesced matMul_gpu_sharedmem 
		python ./matMul.py --Device $(DEVICE_ID)

traces: matMul_gpu_uncoalesced matMul_gpu matMul_gpu_sharedmem_uncoalesced matMul_gpu_sharedmem 
		python ./matMul.py --Traces True --Device $(DEVICE_ID)

metrics: matMul_gpu_uncoalesced matMul_gpu matMul_gpu_sharedmem_uncoalesced matMul_gpu_sharedmem 
		python ./matMul.py  --Metrics True  --Device $(DEVICE_ID)

events: matMul_gpu_uncoalesced matMul_gpu matMul_gpu_sharedmem_uncoalesced matMul_gpu_sharedmem 
		python ./matMul.py  --Events True --Device $(DEVICE_ID)
	
clean:
		rm -rf *.o matMul_gpu_uncoalesced matMul_gpu matMul_gpu_sharedmem_uncoalesced matMul_gpu_sharedmem
