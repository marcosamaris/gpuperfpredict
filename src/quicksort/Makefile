all: quicksort

include ../common/Makefile.common

quicksort.o: quicksort.cu
	$(CC) $(CFLAGS) -c quicksort.cu

quicksort: quicksort.o
	$(CC) $(CFLAGS) quicksort.o -o quicksort

tests: quicksort
	python3 -u ./quicksort.py --Device $(DEVICE_ID)
	
traces: quicksort
	python3 -u ./quicksort.py --Traces True --Device $(DEVICE_ID)

metrics: quicksort
	python3 -u ./quicksort.py  --Metrics True --Device $(DEVICE_ID)

events: quicksort
	python3 -u ./quicksort.py  --Events True --Device $(DEVICE_ID)
	
clean:
	rm -rf *.o quicksort
