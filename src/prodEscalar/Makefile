all: dot_gpu

include ../common/Makefile.common

dot_gpu.o: dot_gpu.cu
	$(CC) $(CFLAGS) -c dot_gpu.cu

dot_gpu: dot_gpu.o common.o
	$(CC) $(CFLAGS) common.o dot_gpu.o -o dot_gpu

profile: dot_gpu
	$(NVPROF) --metrics $(METRICS) ./dot_gpu $(N) $(DEVICE_ID)

tests: dot_gpu
	bash ./run_ex3.sh

clean:
	rm -rf *.o dot_gpu
