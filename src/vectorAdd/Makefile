all: vectorAdd

include ../common/Makefile.common

vectorAdd.o: vectorAdd.cu
	$(CC) $(CFLAGS) -c vectorAdd.cu

vectorAdd: vectorAdd.o
	$(CC) $(CFLAGS) vectorAdd.o -o vectorAdd

tests: vectorAdd
	python ./vectorAdd.py
				 
traces: vectorAdd
	python ./vectorAdd.py --Traces True

metrics: vectorAdd
	python ./vectorAdd.py  --Metrics True

events: vectorAdd
	python ./vectorAdd.py  --Events True				 

clean:
	rm -rf *.o vectorAdd

