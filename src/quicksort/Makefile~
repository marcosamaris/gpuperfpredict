all: quicksort

include ../common/Makefile.common

quicksort.o: quicksort.cu
	$(CC) $(CFLAGS) -c quicksort.cu

quicksort: quicksort.o
	$(CC) $(CFLAGS) quicksort.o -o quicksort

tests: quicksort
	python3 -u ./quicksort.py
	
traces: quicksort
	python3 -u ./quicksort.py --Traces True

metrics: quicksort
	python3 -u ./quicksort.py  --Metrics True

events: quicksort
	python3 -u ./quicksort.py  --Events True
	
clean:
	rm -rf *.o quicksort
