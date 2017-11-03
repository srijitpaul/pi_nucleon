#!/bin/bash -l
#SBATCH -p debug
#SBATCH -n 3072
#SBATCH -N 128

#SBATCH -t 00:30:00
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=s.paul@cyi.ac.cy

#SBATCH -e edison_contract.err
#SBATCH -o edison_contract.out


##MyName=`echo $0 | awk -F\/ '{sub(/^\.\//,"",$0); sub(/\.sh$/,"",$0); print $0}'`
top_level_dir=/scratch2/scratchdirs/srijitp/beta3.31_2hex_24c48_ml-0.09530_mh-0.04/propagators

path_to_qlua=/global/homes/s/srijitp/install/local_20170925_edison/qlua/bin/

scripts=/global/homes/s/srijitp/spaul/projects/pi_nucleon

path_to_prog=$scripts

TSize=48
Thalf=$(($TSize / 2))

include="$scripts/plaquette.qlua  $scripts/timer.qlua $scripts/stout_smear.qlua $scripts/load_gauge_field.qlua $scripts/random_functions.qlua $scripts/gamma_perm_phase.qlua $scripts/gi_dcovi.qlua $scripts/make_mg_solver.qlua $scripts/read_propagator.qlua $scripts/deltapp_piN_openspin.qlua $scripts/deltaM_piN_openspin.qlua $scripts/piN_piN.qlua $scripts/piN_piN_oet.qlua"

configlist_name='/global/homes/s/srijitp/spaul/projects/pi_nucleon/configlist.09'
config_names=`cat $configlist_name`
for config_number in $config_names ;
do
  # gauge configuration number
  g=$config_number

  mkdir -p $top_level_dir/$g && cd $top_level_dir/$g  || exit 1

#  echo "# [$MyName] `date`" > $log
#  pwd >> $log

  nproc=$((4 * 24))
#  echo "# [$MyName] number of processes = $nproc" >> $log

  QLUA_SCRIPT=contractions.qlua


  echo "Starting for config $g"
  source_location_string="$(awk 'BEGIN{}; $1=='$((10#$g))' {printf("{t=%d,pos={%d,%d,%d}};", $5, $2, $3, $4)}END{printf("\n")}' $top_level_dir/source_location.nsrc08perConf )"
  echo "# [$MyName] source location string is \"$source_location_string\" "

  source_location_iterator=0
  sep_src_loc=$(echo $source_location_string | tr ";" "\n")
  for v in $sep_src_loc
  do
    source_location_iterator=$((source_location_iterator + 1))
    echo "source location is {$v} with iterator number $source_location_iterator"
    input="$top_level_dir/$g/contract_params.$g.$source_location_iterator.qlua"
    src_loc_strng="{$v}"
    echo "$src_loc_strng"
    cat $scripts/contract_params.qlua | awk '
    /^source_locations/ {print "'"source_locations = $src_loc_strng"'"; next}
    /^nconf/ {print "nconf = ", '$((10#$g))'; next}
    {print}' > $input
    srun -n $nproc -N 4 -c2 --cpu_bind=cores $path_to_qlua/qlua  $include $input $path_to_prog/$QLUA_SCRIPT >edison_contract_$source_location_iterator.out &
  done
done
wait

##source_location_string="$(awk 'BEGIN{printf("source_locations = { ")}; $1==0 && $2=='$g' && $NF < '$Thalf' {printf("{t=%d, pos={%d, %d, %d}}, ", $6, $3, $4, $5)}; END{printf("}\n")}' $top_level_dir/source_location.nsrc04perConf )"
  ##echo "# [$MyName] source location string is \"$source_location_string\" "
##
##echo $source_location_string
##input="params.$g.qlua"
##
##cat $scripts/params.qlua | awk '
##  /^source_locations/ {print "'"$source_location_string"'"; next}
##  /^nconf/ {print "nconf = ", '$g'; next}
##  {print}' > $input
##

#srun -n $nproc $path_to_qlua/qlua $include $path_to_prog/$QLUA_SCRIPT

##exitStatus=$?
##if [ $exitStatus -ne 0 ]; then
##    echo "[$MyName] Error from srun for $QLUA_SCRIPT, status was $exitStatus"
##      exit 1
##    else
##        echo "# [$MyName] srun finished successfully for $QLUA_SCRIPT, status was $exitStatus"
##      fi
##
##      #QLUA_SCRIPT=invert_contract_oet.qlua
##      #srun -n $nproc $path_to_qlua/qlua $include $input $path_to_prog/$QLUA_SCRIPT
##      #
##      #exitStatus=$?
##      #if [ $exitStatus -ne 0 ]; then
##      #  echo "[$MyName] Error from srun for $QLUA_SCRIPT, status was $exitStatus"
##      #  exit 1
##      #else
##      #  echo "# [$MyName] srun finished successfully for $QLUA_SCRIPT, status was $exitStatus"
##      #fi
##
##echo "# [$MyName] `date`" >> $log
##exit 0
