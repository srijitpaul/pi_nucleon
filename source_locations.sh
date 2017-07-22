#!/bin/bash

MyName=$(echo $0 | awk -F\/ '{sub(/\.sh/,"",$NF);print $NF}')

out=$MyName.tab
log=$MyName.log

echo "# [$MyName] `date`" > $log

L=24
T=48
confFile=conf_all

if [ $# -eq 0 ]; then
  echo -e "# [$MyName] WARNING: no command line arguments provided, keeping default values\n"
else
  while [ "$1" ]; do
    case "$1" in
      "-s") seed=$2; shift 2;;
      "-L") L=$2; shift 2;;
      "-T") T=$2; shift 2;;
      "-c") confFile=$2; shift 2;;
      "-n") nsrc=$2; shift 2;;
      *) exit 1;;
    esac
  done
fi

cat << EOF  > $out
# [$MyName] `date`
# [$MyName] using seed = $seed
# [$MyName] using L = $L
# [$MyName] using T = $T
# [$MyName] using config file = $confFile
# [$MyName] using number of source locations = $nsrc
EOF

RANDOM=seed
RAND_MAX=32768

if ! [ -e $confFile ]; then
  echo "[$MyName] Error, could not find config file"
  exit 1
fi

Conf=($(cat $confFile))

tag=("0" "a" "b" "t")


for g in ${Conf[*]}; do

  gg=$(echo $g | awk '{print $g+0}')

  k=$(( $gg / 10000))
  d=$(( $gg % 10000))

  #  echo "# [] $k $d ${tag[$k]}"
  #  continue

  s0=($(echo "$RANDOM $RANDOM $RANDOM $RANDOM" | awk '
  {
    t = int('$T'*$1/'$RAND_MAX')
    x = int('$L'*$2/'$RAND_MAX')
    y = int('$L'*$3/'$RAND_MAX')
    z = int('$L'*$4/'$RAND_MAX')
    printf("%3d%3d%3d%3d", x, y, z, t)
  }'))

  #  echo " ${s0[0]} ${s0[1]} ${s0[2]} ${s0[3]} "
  #  continue

  printf "%3s%6d%3d%3d%3d%3d\n" ${tag[$k]}  $d  ${s0[*]}


  s1=(${s0[*]})
  for((i=1; i<$nsrc; i++)); do
    s2=($(echo ${s1[*]} | awk '
    {
      t = int($4 + '$T'/'$nsrc'*'$i') % '$T'
      x = int($1 + '$L' / 2) % '$L'
      y = int($2 + '$L' / 2) % '$L'
      z = int($3 + '$L' / 2) % '$L'
      printf("%3d%3d%3d%3d", x, y, z, t)
    }'))

    printf "%3s%6d%3d%3d%3d%3d\n"  ${tag[$k]}  $d  ${s2[*]}

    s1=(${s2[*]})

  done


done >> $out

echo "# [$MyName] `date`" >> $log
exit 0
