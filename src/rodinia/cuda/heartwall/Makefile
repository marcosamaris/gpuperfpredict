include ../../common/init.config

ifdef OUTPUT
override OUTPUT = -DOUTPUT
endif

# link objects(binaries) together
heartwall: main.o ./AVI/avilib.o ./AVI/avimod.o 
	nvcc $(devId) $(FLAGSpecial) $(FLAGArch) main.o ./AVI/avilib.o ./AVI/avimod.o -I/usr/local/cuda/include -o heartwall

# compile main function file into object (binary)
main.o: main.cu kernel.cu define.c
	nvcc $(devId) $(FLAGSpecial) $(FLAGArch) $(OUTPUT) $(KERNEL_DIM) main.cu -I./AVI -c -O3

./AVI/avilib.o ./AVI/avimod.o:
	cd AVI; make;

# delete all object files
clean:
	rm -f *.o AVI/*.o heartwall *.linkinfo
