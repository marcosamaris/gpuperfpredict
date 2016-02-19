all: bitonic

include ../common/Makefile.common

bitonic.o: bitonic_sort.cu
	$(CC) $(CFLAGS) -c bitonic_sort.cu

bitonic: bitonic.o
	$(CC) $(CFLAGS) bitonic_sort.o -o bitonic

tests: bitonic
	python3 -u ./bitonic.py

clean:
	rm -rf *.o bitonic_sort
