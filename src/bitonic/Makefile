all: bitonic

include ../common/Makefile.common

bitonic.o: bitonic_sort.cu
	$(CC) $(CFLAGS) -c bitonic_sort.cu

bitonic: bitonic.o
	$(CC) $(CFLAGS) bitonic_sort.o -o bitonic

tests: bitonic
	python3 -u ./bitonic.py
	
traces: bitonic
	python3 -u ./bitonic.py --Traces True

metrics: bitonic
	python3 -u ./bitonic.py  --Metrics True

events: bitonic
	python3 -u ./bitonic.pyEvents True

clean:
	rm -rf *.o bitonic
