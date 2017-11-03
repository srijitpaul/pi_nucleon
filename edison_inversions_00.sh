#!/bin/bash -l
#SBATCH -p debug
#SBATCH -n 768
#SBATCH -N 32
#SBATCH -t 00:01:30
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=s.paul@cyi.ac.cy

#SBATCH -e edison_00.err
#SBATCH -o edison_00.out


top_level_dir=/scratch2/scratchdirs/srijitp/beta3.31_2hex_24c48_ml-0.09530_mh-0.04/propagators

path_to_qlua=/global/homes/s/srijitp/Local/local_edison/qlua/bin

scripts=/global/homes/s/srijitp/spaul/projects/pi_nucleon

path_to_prog=$scripts

TSize=48
Thalf=$(($TSize / 2))

params=params.qlua
include="$scripts/plaquette.qlua  $scripts/timer.qlua $scripts/stout_smear.qlua $scripts/load_gauge_field.qlua $scripts/random_functions.qlua $scripts/gamma_perm_phase.qlua $scripts/gi_dcovi.qlua $scripts/make_mg_solver.qlua $scripts/write_propagator.qlua $scripts/read_propagator.qlua "


configlist_name="$scripts/configlist.temp1"
config_names=`cat $configlist_name`
for config_number in $config_names ;
do
  # gauge configuration number
  g=$config_number
  echo "Configuration number $g"
  mkdir -p $top_level_dir/$g && cd $top_level_dir/$g  || exit 1

  echo "# `date`" 
  #pwd >> $log

  nproc=$(( 32 * 24 ))
  #echo "# [$MyName] number of processes = $nproc" >> $log

  QLUA_SCRIPT=inversions.qlua
  QLUA_STOCH_SCRIPT=stoch_inversions.qlua

  echo "Starting for config $g"
  

  source_location_string="$(awk 'BEGIN{printf("source_locations = { ")}; $1=='$((10#$g))'{printf("{t=%d, pos={%d, %d, %d}}, ", $5, $2, $3, $4)}; END{printf("}\n")}' $top_level_dir/source_location.nsrc08perConf )"
  echo "# [$MyName] source location string is \"$source_location_string\" "
  input="$top_level_dir/$g/params.$g.qlua"
    
  cat $scripts/invert_params.qlua | awk '
  /^source_locations/ {print "'"$source_location_string"'"; next}
  /^nconf/ {print "nconf = ", '$((10#$g))'; next}
  {print}' > $input

  srun -n $nproc -N 32 -c2 --cpu_bind=cores $path_to_qlua/qlua  $include $input $path_to_prog/$QLUA_SCRIPT >edison_$g.out 
done 




#echo "Forward and Sequential Inversions over, starting stochastic inversions"
#while read -r config_number 
#do
#  # gauge configuration number
#  g=$config_number
#
#  mkdir -p $top_level_dir/$g && cd $top_level_dir/$g  || exit 1
#
#  echo "# [$MyName] `date`" > $log
#  pwd >> $log
#
#  nproc=$(( 32 * 24 ))
#  echo "# [$MyName] number of processes = $nproc" >> $log
#
##  QLUA_SCRIPT=inversions.qlua
#  QLUA_STOCH_SCRIPT=stoch_inversions.qlua
#
##  source_location_string="$(awk 'BEGIN{printf("")}; $2=='$g' && $NF < '$Thalf' {printf("{t=%d,pos={%d,%d,%d}};", $6, $3, $4, $5)}END{printf("\n")}' $top_level_dir/source_location.nsrc08perConf )"
##  echo "# [$MyName] source location string is \"$source_location_string\" "
#  srun -n $nproc -N 32 -c2 --cpu_bind=cores  $path_to_qlua/qlua $include $input $path_to_prog/$QLUA_STOCH_SCRIPT >edison_stoch.out &
#  
#done < "$scripts/configtemp.list"
#wait
exitStatus=$?
if [ $exitStatus -ne 0 ]; then
    echo "[$MyName] Error from srun for $QLUA_SCRIPT, status was $exitStatus"
      exit 1
    else
        echo "# [$MyName] srun finished successfully for $QLUA_SCRIPT, status was $exitStatus"
      fi

#echo "# [$MyName] `date`" >> $log
exit 0
