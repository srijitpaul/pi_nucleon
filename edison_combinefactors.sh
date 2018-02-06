#!/bin/bash -l
#SBATCH -p debug
#SBATCH -n 24
#SBATCH -N 1
#SBATCH -t 00:30:00
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=s.paul@cyi.ac.cy

#SBATCH -e edison_00.err
#SBATCH -o edison_00.out


top_level_dir=/scratch2/scratchdirs/srijitp/beta3.31_2hex_24c48_ml-0.09530_mh-0.04/propagators/tests

path_to_qlua=/global/homes/s/srijitp/install/local_20170925_edison/qlua/bin

scripts=/global/homes/s/srijitp/spaul/projects/pi_nucleon/test/pi_nucleon

path_to_prog=$scripts

TSize=48
Thalf=$(($TSize / 2))

params=combine_params.qlua
include="$scripts/plaquette.qlua  $scripts/timer.qlua $scripts/stout_smear.qlua $scripts/load_gauge_field.qlua $scripts/random_functions.qlua  $scripts/write_propagator.qlua $scripts/read_propagator.qlua $scripts/gamma_lists.qlua"


configlist_name="$scripts/oet_config00"
config_names=`cat $configlist_name`
for config_number in $config_names ;
do
  # gauge configuration number
  g=$config_number
  echo "Configuration number $g"
  mkdir -p $top_level_dir/$g && cd $top_level_dir/$g  || exit 1

  echo "# `date`" 
  #pwd >> $log

  nproc=$(( 1 * 24 ))
  #echo "# [$MyName] number of processes = $nproc" >> $log

  QLUA_SCRIPT=combine_factors.qlua

  echo "Starting for config $g"
  

  source_location_string="$(awk 'BEGIN{printf("source_locations = { ")}; $1=='$((10#$g))'{printf("{t=%d, pos={%d, %d, %d}}, ", $5, $2, $3, $4)}; END{printf("}\n")}' $top_level_dir/testsource  )"
  echo "# [$MyName] source location string is \"$source_location_string\" "
  input="$top_level_dir/$g/params.$g.qlua"
    
  cat $scripts/combine_params.qlua | awk '
  /^source_locations/ {print "'"$source_location_string"'"; next}
  /^nconf/ {print "nconf = ", '$((10#$g))'; next}
  {print}' > $input

  srun -n $nproc -N 1 -c2 --cpu_bind=cores $path_to_qlua/qlua  $include $input $path_to_prog/$QLUA_SCRIPT >edison_combine_$g.out &
done 
wait



exitStatus=$?
if [ $exitStatus -ne 0 ]; then
    echo "[$MyName] Error from srun for $QLUA_SCRIPT, status was $exitStatus"
      exit 1
    else
        echo "# [$MyName] srun finished successfully for $QLUA_SCRIPT, status was $exitStatus"
      fi


exit 0
