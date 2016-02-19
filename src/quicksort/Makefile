all: quicksort

include ../common/Makefile.common

quicksort.o: quicksort.cu
	$(CC) $(CFLAGS) -c quicksort.cu

quicksort: quicksort.o
	$(CC) $(CFLAGS) quicksort.o -o quicksort

tests: quicksort
	python3 -u ./quicksort.py

clean:
	rm -rf *.o quicksort
