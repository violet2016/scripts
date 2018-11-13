timestamp=$(basename "$PWD")
echo $timestamp
id=`psql -qtAX -d hawq-recommend -c "select id from exp_config where exp_time=to_timestamp('$timestamp','yyyy-mm-dd-hh24mi')"`
IFS="
"
for group in `grep group1- ./ip`
do
    podname=`echo $group | grep -o "group1[a-z0-9\-]*"`
    hostname=`echo $group | grep -o "gke-cluster-perf[a-z0-9\-]*"`
    ip=`echo $group | grep -o "10\.[.0-9]*"`
    psql -d hawq-recommend -c  "insert into exp_segments_info(
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