all: transComplexFloat

include ../common/Makefile.common

transComplexFloat.o: transComplexFloat.cu
	$(CC) $(CFLAGS) -c transComplexFloat.cu

transComplexFloat: transComplexFloat.o
	$(CC) $(CFLAGS) transComplexFloat.o -o transComplexFloat

tests: transComplexFloat
	python3 -u ./transComplexFloat.py --Device $(DEVICE_ID)
				 
traces: transComplexFloat
	python3 -u ./transComplexFloat.py --Traces True --Device $(DEVICE_ID)

metrics: transComplexFloat
	python3 -u ./transComplexFloat.py  --Metrics True --Device $(DEVICE_ID)

events: transComplexFloat
	python3 -u ./transComplexFloat.py  --Events True --Device $(DEVICE_ID)				 

clean:
	rm -rf *.o transComplexFloat

