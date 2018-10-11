psql -d hawq-recommend -f create_exp_query_table.sql
pushd $1
timestamp=$(basename "$PWD")
id=`psql -qtAX -d hawq-recommend -c "select id from exp_config where exp_time=to_timestamp('$timestamp','yyyy-mm-dd-hh24mi')"`
for filename in `ls result_test_*.txt`
do
    query_id=`echo $filename | grep -Eo "[0-9]{2}"`
    plan_file="plan_$query_id.sql.txt"
    query_plan_rows=`cat $plan_file | grep -nE "rows)$" | head -1 | grep -oE "^[0-9]+"`
    query_plan_rows_end=$(($query_plan_rows-1))
    sed_expr="4,${query_plan_rows_end}p;${query_plan_rows}q"
    sed -n $sed_expr $plan_file > extract_${query_id}.txt
    hash=`md5 -q extract_${query_id}.txt`
    start_time=`grep "StartTime:" $filename | sed -En "s/StartTime:(.+)/\1/p"`
    end_time=`grep "EndTime:" $filename | sed -En "s/EndTime:(.+)/\1/p"`
    exec_time=`grep "Time: " $filename | sed -En "s/Time:(.+) ms/\1/p"`
    result_lines=`grep "\-\-\-" $filename | wc -l`
    finished="t"
    if [ "$result_lines" -eq "0" ]; then
        finished="f"
    fi
    
    if [ -z $exec_time ]; then
        exec_time="0.0"
    fi
    #echo $query_id $query_plan_rows_end $query_plan_rows $start_time $end_time
    psql -d hawq-recommend -c "
    insert into exp_queries(
        query_id,
        query_plan_rows,
        query_plan_hash,
        start_time,
        end_time,
        total_exec_time_in_ms,
        config_id,
        success
) values(
    $query_id,
    $query_plan_rows,
    '${hash}',
    timestamp with time zone '$start_time UTC',
    timestamp with time zone '$end_time UTC',
    $exec_time,
    $id,
    '$finished'
);"
done
popd