all: subSeqMax

include ../common/Makefile.common

#subSeqMax.o: subSeqMax.cu
#	$(CC) $(CFLAGS) -D_FORCE_INLINES -c subSeqMax.cu

subSeqMax: subSeqMax
	$(CC) $(CFLAGS)  subSeqMax.cu -o subSeqMax

tests: subSeqMax
	python ./subSeqMax.py --Device $(DEVICE_ID)
	
traces: subSeqMax
	python ./subSeqMax.py --Traces True --Device $(DEVICE_ID)

metrics: subSeqMax
	python ./subSeqMax.py  --Metrics True --Device $(DEVICE_ID)

events: subSeqMax
	python ./subSeqMax.py  --Events True --Device $(DEVICE_ID)				 

clean:
	rm -rf *.o subSeqMax

