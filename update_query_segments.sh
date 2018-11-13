psql -d hawq-recommend -f create_query_segs.sql
pushd $1
timestamp=$(basename "$PWD")
config_id=`psql -qtAX -d hawq-recommend -c "select id from exp_config where exp_time=to_timestamp('$timestamp','yyyy-mm-dd-hh24mi')"`
if [ -z "$config_id" ]
then
    echo "not in config yet"
    popd
    exit
fi
python ~/workspace/py-workspace/api_log_parser/main.py ./ $config_id
popd