all: transComplexDouble

include ../common/Makefile.common

transComplexDouble.o: transComplexDouble.cu
	$(CC) $(CFLAGS) -c transComplexDouble.cu

transComplexDouble: transComplexDouble.o
	$(CC) $(CFLAGS) transComplexDouble.o -o transComplexDouble
				 
traces: transComplexDouble
	python ./transComplexDouble.py --Traces True --Device $(DEVICE_ID)

clean:
	rm -rf *.o transComplexDouble

