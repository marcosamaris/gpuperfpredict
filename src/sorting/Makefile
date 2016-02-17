all: quicksort bitonic

include ../common/Makefile.common

quicksort.o: quicksort.cu
	$(CC) $(CFLAGS) -c quicksort.cu

quicksort: quicksort.o
	$(CC) $(CFLAGS) quicksort.o -o quicksort

bitonic.o: bitonic_sort.cu
	$(CC) $(CFLAGS) -c bitonic_sort.cu

bitonic: bitonic.o
	$(CC) $(CFLAGS) bitonic_sort.o -o bitonic

tests: quicksort bitonic
	python3 -u ./sorting.py

clean:
	rm -rf *.o quicksort bitonic_sort
