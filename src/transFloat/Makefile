all: transFloat

include ../common/Makefile.common

transFloat.o: transFloat.cu
	$(CC) $(CFLAGS) -c transFloat.cu

transFloat: transFloat.o
	$(CC) $(CFLAGS) transFloat.o -o transFloat

traces: transFloat
	python ./transFloat.py --Traces True --Device $(DEVICE_ID)

clean:
	rm -rf *.o transFloat

