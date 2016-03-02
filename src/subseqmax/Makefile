all: Subseqmax

include ../common/Makefile.common

Subseqmax.o: Subseqmax.cu
	$(CC) $(CFLAGS) -c Subseqmax.cu

Subseqmax: Subseqmax.o
	$(CC) $(CFLAGS) Subseqmax.o -o Subseqmax

tests: Subseqmax
	python3 -u ./Subseqmax.py
	
traces: Subseqmax
	python3 -u ./Subseqmax.py --Traces True

metrics: Subseqmax
	python3 -u ./Subseqmax.py  --Metrics True

events: Subseqmax
	python3 -u ./Subseqmax.py  --Events True				 

clean:
	rm -rf *.o Subseqmax

