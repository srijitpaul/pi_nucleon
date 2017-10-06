#!/bin/bash -l
#SBATCH -p regular
#SBATCH -n 49152
#SBATCH -N 2048
#SBATCH -t 05:00:00
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=s.paul@cyi.ac.cy
#SBATCH --qos=premium

#SBATCH -e edison_stoch.err
#SBATCH -o edison_stoch.out


top_level_dir=/scratch2/scratchdirs/srijitp/beta3.31_2hex_24c48_ml-0.09530_mh-0.04/propagators

path_to_qlua=/global/homes/s/srijitp/install/local_20170925_edison/qlua/bin

scripts=/global/homes/s/srijitp/spaul/projects/pi_nucleon

path_to_prog=$scripts

TSize=48
Thalf=$(($TSize / 2))

params=params.qlua
include="$scripts/plaquette.qlua  $scripts/timer.qlua $scripts/stout_smear.qlua $scripts/load_gauge_field.qlua $scripts/random_functions.qlua $scripts/gamma_perm_phase.qlua $scripts/gi_dcovi.qlua $scripts/make_mg_solver.qlua $scripts/write_propagator.qlua $scripts/read_propagator.qlua 
$scripts/piN_piN_oet.qlua"

while read -r config_number 
do
  # gauge configuration number
  g=$config_number

  mkdir -p $top_level_dir/$g && cd $top_level_dir/$g  || exit 1


  nproc=$(( 32 * 24 ))


  QLUA_STOCH_SCRIPT=stoch_inversions.qlua
    
  input="$top_level_dir/$g/stochparams.$g.qlua"
  cat $scripts/params.qlua | awk '
      /^source_locations/ {print "'"source_locations = 0"'"; next}
      /^nconf/ {print "nconf = ", '$((10#$g))'; next}
      {print}' > $input
  srun -n $nproc -N 32 -c2 --cpu_bind=cores  $path_to_qlua/qlua $include $input $path_to_prog/$QLUA_STOCH_SCRIPT >edison_stoch.out &
  
done < "$scripts/configstoch.list"
wait
exitStatus=$?
if [ $exitStatus -ne 0 ]; then
    echo "[$MyName] Error from srun for $QLUA_SCRIPT, status was $exitStatus"
      exit 1
    else
        echo "# [$MyName] srun finished successfully for $QLUA_SCRIPT, status was $exitStatus"
      fi

#echo "# [$MyName] `date`" >> $log
exit 0
