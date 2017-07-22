#pragma once
#include <mpi.h>
#include <string>
#include <iostream>
#include <cmath>

/**
 * @brief Holds info on MPI stuff (pretty much world size and world rank).
 */
struct mpi_t {
	int world_size; 
    int world_rank;

};

/**
 * @brief Simple struct to convert between a process' rank and the associated 
 *        (x,y) coordinates in the grid of tiles.
 *
 * @remark Notice that x (the horizontal coordinate) is given first in the 
 *         constructors, whereas in usual matrix notation the row index 
 *         usually comes first.
*/

/**
 * @brief Fills MPI info struct.
 */
void setupMpi(mpi_t &mpi);

