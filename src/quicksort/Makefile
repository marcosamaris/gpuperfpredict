all: quicksort

include ../common/Makefile.common

quicksort.o: quicksort.cu
	$(CC) $(CFLAGS) -c quicksort.cu

quicksort: quicksort.o
	$(CC) $(CFLAGS) quicksort.o -o quicksort

tests: quicksort
	python ./quicksort.py --Device $(DEVICE_ID)
	
traces: quicksort
	python ./quicksort.py --Traces True --Device $(DEVICE_ID)

metrics: quicksort
	python ./quicksort.py  --Metrics True --Device $(DEVICE_ID)

events: quicksort
	python ./quicksort.py  --Events True --Device $(DEVICE_ID)
	
clean:
	rm -rf *.o quicksort
