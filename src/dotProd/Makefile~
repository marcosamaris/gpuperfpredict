all: dotProd

include ../common/Makefile.common

dotProd.o: dotProd.cu
	$(CC) $(CFLAGS) -c dotProd.cu

dotProd: dotProd.o
	$(CC) $(CFLAGS) dotProd.o -o dotProd

tests: dotProd
	python3 -u ./dotProd.py
	
traces: dotProd
	python3 -u ./dotProd.py --Traces True

metrics: dotProd
	python3 -u ./dotProd.py  --Metrics True

events: dotProd
	python3 -u ./dotProd.py  --Events True

clean:
	rm -rf *.o dotProd
