#include "mpi-helpers.hpp"

void setupMpi(mpi_t &mpi) {
    MPI_Comm_rank(MPI_COMM_WORLD, & mpi.world_rank);
    MPI_Comm_size(MPI_COMM_WORLD, & mpi.world_size);
}


