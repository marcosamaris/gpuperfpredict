all: transDouble

include ../common/Makefile.common

transDouble.o: transDouble.cu
	$(CC) $(CFLAGS) -c transDouble.cu

transDouble: transDouble.o
	$(CC) $(CFLAGS) transDouble.o -o transDouble

tests: transDouble
	python3 -u ./transDouble.py --Device $(DEVICE_ID)
				 
traces: transDouble
	python3 -u ./transDouble.py --Traces True  --Device $(DEVICE_ID)

metrics: Subseqmax
	python3 -u ./transDouble.py  --Metrics True --Device $(DEVICE_ID)

events: Subseqmax
	python3 -u ./transDouble.py  --Events True --Device $(DEVICE_ID)				 

clean:
	rm -rf *.o transDouble

