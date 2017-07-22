#!/bin/bash



while read -r conf
	do 
	awk '$1==0 && $2=='$conf' {printf("%.2d\t\t%.2d\t\t%.2d\t\t%.2d\n", $3, $4, $5, $6)}' source_locations> src_$conf
	done <conf.list 
