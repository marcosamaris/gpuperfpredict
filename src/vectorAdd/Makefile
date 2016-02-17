all: vectorAdd

include ../common/Makefile.common

vectorAdd.o: vectorAdd.cu
	$(CC) $(CFLAGS) -c vectorAdd.cu

vectorAdd: vectorAdd.o
	$(CC) $(CFLAGS) vectorAdd.o -o vectorAdd

tests: vectorAdd
	python3 -u ./vectorAdd.py
				 

clean:
	rm -rf *.o vectorAdd

