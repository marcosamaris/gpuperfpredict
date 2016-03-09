all: subSeqMax

include ../common/Makefile.common

subSeqMax.o: subSeqMax.cu
	$(CC) $(CFLAGS) -c subSeqMax.cu

subSeqMax: subSeqMax.o
	$(CC) $(CFLAGS) subSeqMax.o -o subSeqMax

tests: subSeqMax
	python3 -u ./subSeqMax.py
	
traces: subSeqMax
	python3 -u ./subSeqMax.py --Traces True

metrics: subSeqMax
	python3 -u ./subSeqMax.py  --Metrics True

events: subSeqMax
	python3 -u ./subSeqMax.py  --Events True				 

clean:
	rm -rf *.o subSeqMax

