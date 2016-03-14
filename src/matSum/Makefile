all: matrix_sum_normal matrix_sum_coalesced

include ../common/Makefile.common

matrix_sum_normal.o: matrix_sum_normal.cu
	$(CC) $(CFLAGS) -c matrix_sum_normal.cu

matrix_sum_normal: matrix_sum_normal.o
	$(CC) $(CFLAGS) matrix_sum_normal.o -o matrix_sum_normal

matrix_sum_coalesced.o: matrix_sum_coalesced.cu
	$(CC) $(CFLAGS) -c matrix_sum_coalesced.cu

matrix_sum_coalesced: matrix_sum_coalesced.o 
	$(CC) $(CFLAGS) matrix_sum_coalesced.o -o matrix_sum_coalesced

tests: matrix_sum_normal matrix_sum_coalesced
	python ./matSum.py --Device $(DEVICE_ID)

traces: matrix_sum_normal matrix_sum_coalesced
	python ./matSum.py --Traces True --Device $(DEVICE_ID)

metrics: matrix_sum_normal matrix_sum_coalesced
	python ./matSum.py  --Metrics True --Device $(DEVICE_ID)

events: matrix_sum_normal matrix_sum_coalesced
	python ./matSum.py  --Events True --Device $(DEVICE_ID)

clean:
	rm -rf *.o matrix_sum_normal matrix_sum_coalesced
