#!/bin/bash -l
MyName=`echo $0 | awk -F\/ '{sub(/^\.\//,"",$0); sub(/\.sh$/,"",$0); print $0}'`
top_level_dir=/home/srijit/Dropbox/spaul/Dina_Work/pion_nucleon/propagators
log=$MyName.log


scripts=/home/srijit/Dropbox/spaul/Dina_Work/pion_nucleon_scripts/edison/pi_nucleon

path_to_prog=$scripts

TSize=16
Thalf=$(($TSize / 2))

params=sandbox_params.qlua

include="$scripts/plaquette.qlua  $scripts/timer.qlua $scripts/stout_smear.qlua $scripts/load_gauge_field.qlua $scripts/random_functions.qlua  $scripts/make_mg_solver.qlua $scripts/write_propagator.qlua $scripts/read_propagator.qlua $scripts/deltapp_piN_openspin.qlua $scripts/gamma_lists.qlua $scripts/contract_factors.qlua $scripts/deltaM_piN_openspin.qlua"

# gauge configuration number
g=230031

mkdir -p $top_level_dir/$g && cd $top_level_dir/$g  || exit 1

echo "# [$MyName] `date`" > $log
pwd >> $log

echo "# [$MyName] number of processes = $nproc" >> $log

source_location_string="$(awk 'BEGIN{printf("source_locations = { ")}; $1==0 && $2=='$g' && $NF < '$Thalf' {printf("{t=%d, pos={%d, %d, %d}}, ", $6, $3, $4, $5)}; END{printf("}\n")}' $top_level_dir/source_location.nsrc04perConf )"
echo "# [$MyName] source location string is \"$source_location_string\" "

input="params.$g.qlua"

cat $scripts/sandbox_params.qlua | awk '
  /^source_locations/ {print "'"$source_location_string"'"; next}
  /^nconf/ {print "nconf = ", '$g'; next}
  {print}' > $input


QLUA_SCRIPT=invert_contract.qlua

mpirun -n 2 qlua $include $input $path_to_prog/$QLUA_SCRIPT

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
