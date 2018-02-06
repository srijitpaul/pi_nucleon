#!/bin/bash -l

top_level_dir=/home/srijit/Dropbox/spaul/Dina_Work/pion_nucleon/propagators/tests

path_to_qlua=/global/homes/s/srijitp/install/local_20170925_edison/qlua/bin

scripts=/home/srijit/Dropbox/spaul/Dina_Work/pion_nucleon_scripts/tests/pi_nucleon

path_to_prog=$scripts

TSize=16
Thalf=$(($TSize / 2))

include="$scripts/plaquette.qlua  $scripts/timer.qlua $scripts/stout_smear.qlua $scripts/load_gauge_field.qlua $scripts/random_functions.qlua $scripts/gamma_perm_phase.qlua $scripts/gi_dcovi.qlua $scripts/make_mg_solver.qlua $scripts/write_propagator.qlua $scripts/read_propagator.qlua 
$scripts/piN_piN_oet.qlua"

configlist_name='/home/srijit/Dropbox/spaul/Dina_Work/pion_nucleon_scripts/tests/pi_nucleon/oet_config00'
config_names=`cat $configlist_name`

for config_number in $config_names ;
do
  # gauge configuration number
  g=$config_number
  echo "Configuration number $g"
  mkdir -p $top_level_dir/$g && cd $top_level_dir/$g  || exit 1

  echo "# `date`" 
  #pwd >> $log

  nproc=$(( 2 ))
  #echo "# [$MyName] number of processes = $nproc" >> $log

  QLUA_SCRIPT=oet_inversions.qlua

  echo "Starting for config $g"
  

  source_location_string="$(awk 'BEGIN{printf("source_locations = { ")}; $1=='$((10#$g))'{printf("{t=%d, pos={%d, %d, %d}}, ", $5, $2, $3, $4)}; END{printf("}\n")}' $top_level_dir/testsource )"
  echo "# [$MyName] source location string is \"$source_location_string\" "
  input="$top_level_dir/$g/params.$g.qlua"
    
  cat $scripts/oet_params.qlua | awk '
  /^source_locations/ {print "'"$source_location_string"'"; next}
  /^nconf/ {print "nconf = ", '$((10#$g))'; next}
  {print}' > $input

  mpirun -n 2 qlua_170925  $include $input $path_to_prog/$QLUA_SCRIPT >edison_$g.out 
done 
wait
#for config_number in $config_names ;
#do
#  # gauge configuration number
#  g=$config_number
#  echo "Configuration number $g"
#  mkdir -p $top_level_dir/$g && cd $top_level_dir/$g  || exit 1
#
#  #echo "# [$MyName] `date`" > $log
#  #pwd >> $log
#
#  nproc=$(( 32 * 24 ))
#  #echo "# [$MyName] number of processes = $nproc" >> $log
#
#  QLUA_SCRIPT=oet_inversions.qlua
#
#  echo "Starting for config $g"
#  
#  source_location_string="$(awk 'BEGIN{}; $1=='$((10#$g))' {printf("{t=%d,pos={%d,%d,%d}};", $5, $2, $3, $4)}END{printf("\n")}' $top_level_dir/source_location.nsrc08perConf )"
#  echo "# [$MyName] source location string is \"$source_location_string\" "
#
#  source_location_iterator=0
#  sep_src_loc=$(echo $source_location_string | tr ";" "\n")
#  for v in $sep_src_loc
#  do
#    source_location_iterator=$((source_location_iterator + 1))
#    echo "source location is {$v} with iterator number $source_location_iterator"
#    input="$top_level_dir/$g/oet_params.$g.$source_location_iterator.qlua"
#    src_loc_strng="{$v}"
#    echo "$src_loc_strng"
#    cat $scripts/oet_params.qlua | awk '
#    /^source_locations/ {print "'"source_locations = $src_loc_strng"'"; next}
#    /^nconf/ {print "nconf = ", '$((10#$g))'; next}
#    {print}' > $input
#
#    srun -n $nproc -N 32 -c2 --cpu_bind=cores $path_to_qlua/qlua  $include $input $path_to_prog/$QLUA_SCRIPT >oet_edison_$source_location_iterator.out &
#  done
#done 
#wait
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
