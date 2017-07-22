#!/bin/bash -l


#SBATCH -p debug
#SBATCH -N 41
#SBATCH -C knl,quad,cache
#SBATCH -t 30:00
#SBATCH -J 2592_6c12_knl_mg 
#SBATCH -o 1_6c12_2592.out 
#SBATCH -e 1_6c12_2592.err 

export  OMP_NUM_THREADS=1
sbcast --compress=lz4 ./qlua_avx512_cori /tmp/qlua_avx512_cori

srun -n 2592 -c 4 --cpu_bind=cores ./qlua_avx512_cori  plaquette.qlua load_gauge_field.qlua stout_smear.qlua 1.qlua 

