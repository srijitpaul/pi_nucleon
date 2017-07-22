#!/bin/bash

MyName=`echo $0 | awk -F\/ '{sub(/^\.\//,"",$0); sub(/\.sh$/,"",$0); print $0}'`
top_level_dir=/scratch2/scratchdirs/srijitp/beta3.31_2hex_24c48_ml-0.09530_mh-0.04/propagators
log=$MyName.log

Conf=(1092)

for g in ${Conf[*]}; do

  job=job.$g.slurm

  cat $top_level_dir/job.sh | awk '
    /^g=/ {print "g='$g'"; next}
    {print}' > $job

  sbatch $job >> $top_level_dir/README
done

exit 0
