all: subSeqMax

include ../common/Makefile.common

subSeqMax.o: subSeqMax.cu
	$(CC) $(CFLAGS) -c subSeqMax.cu

subSeqMax: subSeqMax.o
	$(CC) $(CFLAGS) subSeqMax.o -o subSeqMax

tests: subSeqMax
	python ./subSeqMax.py
	
traces: subSeqMax
	python ./subSeqMax.py --Traces True

metrics: subSeqMax
	python ./subSeqMax.py  --Metrics True

events: subSeqMax
	python ./subSeqMax.py  --Events True				 

clean:
	rm -rf *.o subSeqMax

