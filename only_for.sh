for d in $(find $1 -maxdepth 1 -type d)
do
    echo $d
    ./only_test.sh $d 10
done
./only_update_samples.sh $2