all: Subseqmax

include ../common/Makefile.common

Subseqmax.o: Subseqmax.cu
	$(CC) $(CFLAGS) -c Subseqmax.cu

Subseqmax: Subseqmax.o common.o
	$(CC) $(CFLAGS) common.o Subseqmax.o -o Subseqmax

profile: Subseqmax
	$(NVPROF) --metrics $(METRICS) ./Subseqmax $(N) $(DEVICE_ID)

tests: Subseqmax
	python3 -u ./Subseqmax.py
				 

clean:
	rm -rf *.o Subseqmax

