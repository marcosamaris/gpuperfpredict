all: dotProd

include ../common/Makefile.common

dotProd.o: dotProd.cu
	$(CC) $(CFLAGS) -c dotProd.cu

dotProd: dotProd.o
	$(CC) $(CFLAGS) dotProd.o -o dotProd

tests: dotProd
	python3 -u ./dotProd.py

clean:
	rm -rf *.o dotProd
