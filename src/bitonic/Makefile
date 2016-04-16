all: bitonic

include ../common/Makefile.common

bitonic.o: bitonic_sort.cu
	$(CC) $(CFLAGS) -c bitonic_sort.cu

bitonic: bitonic.o
	$(CC) $(CFLAGS) bitonic_sort.o -o bitonic

tests: bitonic
	python ./bitonic.py --Device $(DEVICE_ID)
	
traces: bitonic
	python ./bitonic.py --Traces True --Device $(DEVICE_ID)

metrics: bitonic
	python ./bitonic.py  --Metrics True --Device $(DEVICE_ID)

events: bitonic
	python ./bitonic.py  --Events True --Device $(DEVICE_ID)

clean:
	rm -rf *.o bitonic
