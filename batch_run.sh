#!/bin/bash
data=20
maxcpu=60000
maxstorage=100000
for size in `seq 30 -5 10`;
do
#size=35
    for cpu in `seq 2000 -500 500`
    do
#cpu=500
        totalcpu=$((cpu*size))
        if [ $totalcpu -gt $maxcpu ]; then
            echo "max cpu exceed, skip this round"
            continue
        fi
        totalstorage=$((2000*size))
        if [ $totalstorage -gt $maxstorage ]; then
            echo "max storage exceed, skip this round"
            continue
        fi
        for mem in `seq 2000 -500 500`
        do
            if [ $size -eq 50 ] && [ $cpu -eq 1000 ] && [ $mem -eq 2000 ]; then
                echo "runned, skip"
                continue
            fi
            echo "***** config size=$size cpu=$cpu mem=$mem storage=2000 data=$data"
            ./run_single_round.sh $size $cpu $mem 2000 $data
        done
    done
done    
