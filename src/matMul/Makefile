all:  matMul_gpu_uncoalesced matMul_gpu matMul_gpu_sharedmem_uncoalesced matMul_gpu_sharedmem

include ../common/Makefile.common

matMul_gpu_uncoalesced.o: matMul_gpu_uncoalesced.cu
	$(CC) $(CFLAGS) -c matMul_gpu_uncoalesced.cu

matMul_gpu_uncoalesced: matMul_gpu_uncoalesced.o common.o
	$(CC) $(CFLAGS) common.o matMul_gpu_uncoalesced.o -o matMul_gpu_uncoalesced

matMul_gpu.o: matMul_gpu.cu
	$(CC) $(CFLAGS) -c matMul_gpu.cu

matMul_gpu: matMul_gpu.o common.o
	$(CC) $(CFLAGS) common.o matMul_gpu.o -o matMul_gpu

matMul_gpu_sharedmem_uncoalesced.o: matMul_gpu_sharedmem_uncoalesced.cu
	$(CC) $(CFLAGS) -c matMul_gpu_sharedmem_uncoalesced.cu

matMul_gpu_sharedmem_uncoalesced: matMul_gpu_sharedmem_uncoalesced.o common.o
	$(CC) $(CFLAGS) common.o matMul_gpu_sharedmem_uncoalesced.o -o matMul_gpu_sharedmem_uncoalesced

matMul_gpu_sharedmem.o: matMul_gpu_sharedmem.cu
	$(CC) $(CFLAGS) -c matMul_gpu_sharedmem.cu

matMul_gpu_sharedmem: matMul_gpu_sharedmem.o common.o
	$(CC) $(CFLAGS) common.o matMul_gpu_sharedmem.o -o matMul_gpu_sharedmem

tests: matMul_gpu_uncoalesced matMul_gpu matMul_gpu_sharedmem_uncoalesced matMul_gpu_sharedmem 
	python3 -u ./matmul.py

clean:
	rm -rf *.o matmul_gpu matmul_gpu_uncoalesced
