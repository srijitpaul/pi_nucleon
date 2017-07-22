#!/bin/bash



while read -r conf
        do
        awk '
	{ gsub (/nconf = ;/, "nconf='$conf';"); print}
	' parallel_extract.cpp> parallel_extract_$conf.cpp
	cc -openmp -o mpi_parallel_extract_$conf.out mpi-helpers.cpp parallel_extract_$conf.cpp -L/global/homes/s/srijitp/spaul/build2/parts/aff/tree/lib -llhpc-aff
	mkdir mxm_mxm_$conf
	done <conf.list

echo "#!/bin/bash -l


#SBATCH -p debug
#SBATCH -N 27
#SBATCH -t 00:30:00
#SBATCH -J pion
#SBATCH -o pion.out
#SBATCH -e pion.err">extract_mxm_mxm_direct.sh
while read -r conf
        do
	echo "srun -n 729 mpi_parallel_extract_"$conf".out"
	done<conf.list
