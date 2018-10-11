all_check=`psql -qtAX -d hawq-recommend -c "select id, to_char(exp_time, 'yyyy-mm-dd-hh24mi'), data_size from exp_config"`

for check in $all_check
do
    IFS='|' read -r -a array <<< "$check"
    id=${array[0]}
    time=${array[1]}
    data_size=${array[2]}
    folder="/Users/vcheng/workspace/data/hawq-tpch/${time:0:10}/$time"
    ./to_db_plan_info.sh "$folder" $data_size
done