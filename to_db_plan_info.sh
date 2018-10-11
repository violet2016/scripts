psql -d hawq-recommend -f create_query_plan_table.sql
pushd $1
for filename in `ls extract_*`
do
    query_id=`echo $filename | grep -Eo "[0-9]{2}"`
    hash=`md5 -q $filename`
    python /Users/vcheng/workspace/py-workspace/pgplanparser/main.py $filename op > op_temp_$query_id.txt
    sed 's/"/\\"/g' op_temp_$query_id.txt > op_temp_$query_id.txt.bak
    sleep 0.01
    #oplist=`cat op_temp_$query_id.txt.bak | awk '{ print "\""$0"\""}' | paste -s -d ',' -`
    oplist=`cat op_temp_$query_id.txt.bak | paste -s -d ',' -`
    rm op_temp_$query_id.txt.bak 
    rm op_temp_$query_id.txt
    echo $oplist
    tablelist=`python /Users/vcheng/workspace/py-workspace/pgplanparser/main.py $filename table | awk '{ print "\""$0"\""}' | paste -s -d ',' -`
    psql -d hawq-recommend -c "
    insert into query_plan_info(
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