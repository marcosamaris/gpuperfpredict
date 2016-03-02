all: dotProd

include ../common/Makefile.common

dotProd.o: dotProd.cu
	$(CC) $(CFLAGS) -c dotProd.cu

dotProd: dotProd.o
	$(CC) $(CFLAGS) dotProd.o -o dotProd

tests: dotProd
	python3 -u ./dotProd.py --Device $(DEVICE_ID)
	
traces: dotProd
	python3 -u ./dotProd.py --Traces True --Device $(DEVICE_ID)

metrics: dotProd
	python3 -u ./dotProd.py  --Metrics True --Device $(DEVICE_ID)

events: dotProd
	python3 -u ./dotProd.py  --Events True --Device $(DEVICE_ID)

clean:
	rm -rf *.o dotProd
