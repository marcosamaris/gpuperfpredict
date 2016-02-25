all: vectorTrans

include ../common/Makefile.common

vectorTrans.o: vectorTrans.cu
	$(CC) $(CFLAGS) -c vectorTrans.cu

vectorTrans: vectorTrans.o
	$(CC) $(CFLAGS) vectorTrans.o -o vectorTrans

tests: vectorTrans
	python3 -u ./vectorTrans.py
				 
traces: vectorTrans
	python3 -u ./vectorTrans.py --Traces True

metrics: Subseqmax
	python3 -u ./vectorTrans.py  --Metrics True

events: Subseqmax
	python3 -u ./vectorTrans.py  --Events True				 

clean:
	rm -rf *.o vectorTrans

