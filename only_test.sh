echo "===to db config==="
./to_db_config.sh $1 $2 #datasize
echo "===exec info==="
./only_exec_info.sh $1
echo "===db prometheus==="
./to_db_prometheus.sh $1
echo "===update query segments==="
./update_query_segments.sh $1
