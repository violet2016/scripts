psql -d hawq-recommend -f create_exp_config_table.sql
pushd $1
# groupsize=`grep groupSize *.yaml | grep -Eo "[0-9]{1,3}"`
# cpusize=`grep cpu *.yaml | tail -1 | grep -Eo "[0-9]{2,5}" | head -1`
# memsize=`grep memory *.yaml | tail -1 | grep -Eo "[0-9]{2,5}" | head -1`
# storagesize=`grep ephemeralStorage *.yaml | tail -1 | grep -Eo "[0-9]{2,5}" | head -1`
# timestamp=$(basename "$PWD")
# psql -d hawq-recommend -c "insert into exp_config(group_size, mem_size, cpu_size, storage_size, exp_time) values
#     ( $groupsize, 
#      $memsize,
#      $cpusize,
#      $storagesize,
#     to_timestamp('$timestamp', 'yyyy-mm-dd-hh24mi'))
# "

groups=`grep group1- ip`
for group in $groups
do
    cols=$(echo $group | tr "\t" "\n")
    echo "columns $cols"
done
popd