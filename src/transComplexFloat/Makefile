all: transComplexFloat

include ../common/Makefile.common

transComplexFloat.o: transComplexFloat.cu
	$(CC) $(CFLAGS) -c transComplexFloat.cu

transComplexFloat: transComplexFloat.o
	$(CC) $(CFLAGS) transComplexFloat.o -o transComplexFloat
				 
traces: transComplexFloat
	python ./transComplexFloat.py --Traces True --Device $(DEVICE_ID)		 

clean:
	rm -rf *.o transComplexFloat

