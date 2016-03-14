all: transDouble

include ../common/Makefile.common

transDouble.o: transDouble.cu
	$(CC) $(CFLAGS) -c transDouble.cu

transDouble: transDouble.o
	$(CC) $(CFLAGS) transDouble.o -o transDouble

traces: transDouble
	python ./transDouble.py --Traces True  --Device $(DEVICE_ID)

clean:
	rm -rf *.o transDouble

