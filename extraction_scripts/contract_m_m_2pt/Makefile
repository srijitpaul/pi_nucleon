CC = cc
CFLAGS = -openmp
FILES = mpi-helpers.cpp parallel_extract_ll.cpp
TARGET = mpi_parallel_extract_ll.out  
LDFLAGS = -L/global/homes/s/srijitp/spaul/build2/parts/aff/tree/lib -llhpc-aff

build: $(FILES)
	$(CC) $(CFLAGS) -o $(TARGET) $(FILES) $(LDFLAGS)

clean:
	rm -f *.o core

rebuild: clean build 
