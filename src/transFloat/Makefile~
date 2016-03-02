all: transFloat

include ../common/Makefile.common

transFloat.o: transFloat.cu
	$(CC) $(CFLAGS) -c transFloat.cu

transFloat: transFloat.o
	$(CC) $(CFLAGS) transFloat.o -o transFloat

tests: transFloat
	python3 -u ./transFloat.py --Device $(DEVICE_ID)
				 
traces: transFloat
	python3 -u ./transFloat.py --Traces True --Device $(DEVICE_ID)

metrics: Subseqmax
	python3 -u ./transFloat.py  --Metrics True --Device $(DEVICE_ID)

events: Subseqmax
	python3 -u ./transFloat.py  --Events True --Device $(DEVICE_ID)				 

clean:
	rm -rf *.o transFloat

