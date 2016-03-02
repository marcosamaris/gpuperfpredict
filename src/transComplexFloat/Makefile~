all: transComplexFloat

include ../common/Makefile.common

transComplexFloat.o: transComplexFloat.cu
	$(CC) $(CFLAGS) -c transComplexFloat.cu

transComplexFloat: transComplexFloat.o
	$(CC) $(CFLAGS) transComplexFloat.o -o transComplexFloat

tests: transComplexFloat
	python3 -u ./transComplexFloat.py
				 
traces: transComplexFloat
	python3 -u ./transComplexFloat.py --Traces True

metrics: transComplexFloat
	python3 -u ./transComplexFloat.py  --Metrics True

events: transComplexFloat
	python3 -u ./transComplexFloat.py  --Events True				 

clean:
	rm -rf *.o transComplexFloat

