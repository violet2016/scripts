psql -d hawq-recommend -f create_exp_config_table.sql
pushd $1
groupsize=`grep groupSize *.yaml | grep -Eo "[0-9]{1,3}"`
cpusize=`grep cpu *.yaml | tail -1 | grep -Eo "[0-9]{2,5}" | head -1`
memsize=`grep memory *.yaml | tail -1 | grep -Eo "[0-9]{2,5}" | head -1`
storagesize=`grep ephemeralStorage *.yaml | tail -1 | grep -Eo "[0-9]{2,5}" | head -1`
timestamp=$(basename "$PWD")
psql -d hawq-recommend -c "insert into exp_config(
    group_size, 
    mem_size, 
    cpu_size, 
    storage_size, 
    data_size,
    exp_time) 
    values
    ( $groupsize, 
     $memsize,
     $cpusize,
     $storagesize,
     $2,
    to_timestamp('$timestamp', 'yyyy-mm-dd-hh24mi'))
"
id=`psql -qtAX -d hawq-recommend -c "select id from exp_config where exp_time=to_timestamp('$timestamp','yyyy-mm-dd-hh24mi')"`

IFS="
"
#groups=($(grep group1- ip))
for group in `grep group1- ip`
do
    podname=`echo $group | grep -o "group1[a-z0-9\-]*"`
    hostname=`echo $group | grep -o "gke-cluster-perf[a-z0-9\-]*"`
    ip=`echo $group | grep -o "10.[.0-9]*"`
    psql -d hawq-recommend -c "insert into exp_segments_info(
        pod_name, host_name, exp_time, ip, config_id)
        values (
            '$podname', 
            '$hostname', 
            to_timestamp('$timestamp', 'yyyy-mm-dd-hh24mi'),
            '$ip',
            $id
            )
        "
done
unset IFS
popd