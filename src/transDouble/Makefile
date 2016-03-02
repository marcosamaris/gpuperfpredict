all: TransDouble

include ../common/Makefile.common

TransDouble.o: TransDouble.cu
	$(CC) $(CFLAGS) -c TransDouble.cu

TransDouble: TransDouble.o
	$(CC) $(CFLAGS) TransDouble.o -o TransDouble

tests: TransDouble
	python3 -u ./TransDouble.py
				 
traces: TransDouble
	python3 -u ./TransDouble.py --Traces True

metrics: Subseqmax
	python3 -u ./TransDouble.py  --Metrics True

events: Subseqmax
	python3 -u ./TransDouble.py  --Events True				 

clean:
	rm -rf *.o TransDouble

