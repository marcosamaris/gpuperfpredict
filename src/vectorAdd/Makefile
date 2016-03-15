all: vectorAdd

include ../common/Makefile.common

vectorAdd.o: vectorAdd.cu
	$(CC) $(CFLAGS) -c vectorAdd.cu

vectorAdd: vectorAdd.o
	$(CC) $(CFLAGS) vectorAdd.o -o vectorAdd

tests: vectorAdd
	python ./vectorAdd.py --Device $(DEVICE_ID)
				 
traces: vectorAdd
	python ./vectorAdd.py --Traces True --Device $(DEVICE_ID)

metrics: vectorAdd
	python ./vectorAdd.py  --Metrics True --Device $(DEVICE_ID)

events: vectorAdd
	python ./vectorAdd.py  --Events True	 --Device $(DEVICE_ID)			 

clean:
	rm -rf *.o vectorAdd

