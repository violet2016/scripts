pushd $1
#timestamp=$(basename "$PWD")
timestamp=$2
id=`psql -qtAX -d hawq-recommend -c "select id from exp_config where exp_time=to_timestamp('$timestamp','yyyy-mm-dd-hh24mi')"`
for plan_file in `ls plan_*.txt`
do
    echo $plan_file
    query_id=`echo $plan_file | grep -Eo "[0-9]{2}"`
    query_plan_rows=`cat $plan_file | grep -nE "rows)$" | head -1 | grep -oE "^[0-9]+"`
    query_plan_rows_end=$(($query_plan_rows-1))
    sed_expr="4,${query_plan_rows_end}p;${query_plan_rows}q"
    sed -n $sed_expr $plan_file > extract_${query_id}.txt
    hash=`md5 -q extract_${query_id}.txt`
    echo $query_id $hash $query_plan_rows
    result_lines=`grep "\-\-\-" $plan_file | wc -l`
    finished="t"
    if [ "$result_lines" -eq "0" ]; then
        finished="f"
    fi
    tablelist=`python ~/workspace/py-workspace/pgplanparser/main.py extract_${query_id}.txt table | awk '{ print "\""$0"\""}' | paste -s -d ',' -`
    echo $tablelist
    psql -d hawq-recommend -c "update exp_queries set query_plan_hash = '${hash}', query_plan_rows = $query_plan_rows where config_id=$id and query_id=$query_id"
    python /Users/vcheng/workspace/py-workspace/pgplanparser/main.py extract_${query_id}.txt op > op_temp_$query_id.txt
    sed 's/"/\\"/g' op_temp_$query_id.txt > op_temp_$query_id.txt.bak
    sleep 0.01
    #oplist=`cat op_temp_$query_id.txt.bak | awk '{ print "\""$0"\""}' | paste -s -d ',' -`
    oplist=`cat op_temp_$query_id.txt.bak | paste -s -d ',' -`
    rm op_temp_$query_id.txt.bak 
    rm op_temp_$query_id.txt
    echo $oplist
    tablelist=`python /Users/vcheng/workspace/py-workspace/pgplanparser/main.py extract_${query_id}.txt table | awk '{ print "\""$0"\""}' | paste -s -d ',' -`
    psql -d hawq-recommend -c "insert into query_plan_info(
        query_id,
        query_plan_hash,
        query_plan_db,
        query_plan_op_list,
        query_plan_table_name
) values(
    $query_id,
    '${hash}',
    'tpch_parquet_$2gpn_snappy_part_random_gpadmin',
    '{$oplist}',
    '{$tablelist}'
);"
done
popd