all: vectorAdd

include ../common/Makefile.common

vectorAdd.o: vectorAdd.cu
	$(CC) $(CFLAGS) -c vectorAdd.cu

vectorAdd: vectorAdd.o
	$(CC) $(CFLAGS) vectorAdd.o -o vectorAdd

tests: vectorAdd
	python3 -u ./vectorAdd.py
				 
traces: vectorAdd
	python3 -u ./vectorAdd.py --Traces True

metrics: vectorAdd
	python3 -u ./vectorAdd.py  --Metrics True

events: vectorAdd
	python3 -u ./vectorAdd.py  --Events True				 

clean:
	rm -rf *.o vectorAdd

