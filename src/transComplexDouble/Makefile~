all: transComplexDouble

include ../common/Makefile.common

transComplexDouble.o: transComplexDouble.cu
	$(CC) $(CFLAGS) -c transComplexDouble.cu

transComplexDouble: transComplexDouble.o
	$(CC) $(CFLAGS) transComplexDouble.o -o transComplexDouble

tests: transComplexDouble
	python3 -u ./transComplexDouble.py --Device $(DEVICE_ID)
				 
traces: transComplexDouble
	python3 -u ./transComplexDouble.py --Traces True --Device $(DEVICE_ID)

metrics: transComplexDouble
	python3 -u ./transComplexDouble.py  --Metrics True --Device $(DEVICE_ID)

events: transComplexDouble
	python3 -u ./transComplexDouble.py  --Events True --Device $(DEVICE_ID)			 

clean:
	rm -rf *.o transComplexDouble

