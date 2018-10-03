for size in `seq 35 -5 10`;
do
    for cpu in `seq 2000 -500 500`
    do
        for mem in `seq 2000 -500 500`
        do
            echo "***** config size=$size cpu=$cpu mem=$mem storage=2000 data=10"
            ./run_single_round.sh $size $cpu $mem 2000 10
        done
    done
done    