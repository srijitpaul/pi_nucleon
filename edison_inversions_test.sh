#!/bin/bash -l
#SBATCH -p debug
#SBATCH -n 6144
#SBATCH -N 256

#SBATCH -t 00:30:00
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=s.paul@cyi.ac.cy

#SBATCH -e edison.err
#SBATCH -o edison.out


MyName=`echo $0 | awk -F\/ '{sub(/^\.\//,"",$0); sub(/\.sh$/,"",$0); print $0}'`
top_level_dir=/scratch2/scratchdirs/srijitp/beta3.31_2hex_24c48_ml-0.09530_mh-0.04/propagators
log=$MyName.log

path_to_qlua=/global/homes/s/srijitp/Local/local_edison/qlua/bin

scripts=/global/homes/s/srijitp/spaul/projects/pi_nucleon

path_to_prog=$scripts

TSize=48
Thalf=$(($TSize / 2))

params=params.qlua
include="$scripts/plaquette.qlua  $scripts/timer.qlua $scripts/stout_smear.qlua $scripts/load_gauge_field.qlua $scripts/random_functions.qlua $scripts/gamma_perm_phase.qlua $scripts/gi_dcovi.qlua $scripts/make_mg_solver.qlua $scripts/write_propagator.qlua $scripts/read_propagator.qlua"

# gauge configuration number
g=230031

mkdir -p $top_level_dir/$g && cd $top_level_dir/$g  || exit 1

echo "# [$MyName] `date`" > $log
pwd >> $log

nproc=$(( 32 * 24 ))
echo "# [$MyName] number of processes = $nproc" >> $log

QLUA_SCRIPT=inversions.qlua
QLUA_STOCH_SCRIPT=stoch_inversions.qlua

source_location_string="$(awk 'BEGIN{printf("")}; $1==0 && $2=='$g' && $NF < '$Thalf' {printf("{t=%d,pos={%d,%d,%d}};", $6, $3, $4, $5)}END{printf("\n")}' $top_level_dir/source_location.nsrc04perConf )"
echo "# [$MyName] source location string is \"$source_location_string\" "

source_location_iterator=0
sep_src_loc=$(echo $source_location_string | tr ";" "\n")
for v in $sep_src_loc
do

  source_location_iterator=$((source_location_iterator + 1))
  echo "source location is {$v} with iterator number $source_location_iterator"
  input="$top_level_dir/$g/params.$g.$source_location_iterator.qlua"
  src_loc_strng="{$v}"
  echo "$src_loc_strng"
  cat $scripts/params.qlua | awk '
  /^source_locations/ {print "'"source_locations = $src_loc_strng"'"; next}
  /^nconf/ {print "nconf = ", '$g'; next}
  {print}' > $input
  
  srun -n $nproc -N 32 -c2 --cpu_bind=cores $path_to_qlua/qlua  $include $input $path_to_prog/$QLUA_SCRIPT >edison_$source_location_iterator.out &
done
wait
srun -n 768  $path_to_qlua/qlua $include $input $path_to_prog/$QLUA_STOCH_SCRIPT >edison_stoch.out

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

exitStatus=$?
if [ $exitStatus -ne 0 ]; then
    echo "[$MyName] Error from srun for $QLUA_SCRIPT, status was $exitStatus"
      exit 1
    else
        echo "# [$MyName] srun finished successfully for $QLUA_SCRIPT, status was $exitStatus"
      fi

      #QLUA_SCRIPT=invert_contract_oet.qlua
      #srun -n $nproc $path_to_qlua/qlua $include $input $path_to_prog/$QLUA_SCRIPT
      #
      #exitStatus=$?
      #if [ $exitStatus -ne 0 ]; then
      #  echo "[$MyName] Error from srun for $QLUA_SCRIPT, status was $exitStatus"
      #  exit 1
      #else
      #  echo "# [$MyName] srun finished successfully for $QLUA_SCRIPT, status was $exitStatus"
      #fi

echo "# [$MyName] `date`" >> $log
exit 0
