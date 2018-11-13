#!/bin/bash
if [ $# -ne 3 ]; then
    echo -e "\nUsage:\t $0 HOSTNAME START END REPEAT_TIME\n"
    exit 1
fi
DIFF=$(($3-$2+1))
RANDOM=$$
for i in `seq $4`
do
    R=$(($(($RANDOM%$DIFF))+$1))
    echo $R
    psql -h $1 -U gpadmin -f ./tpch_sqls/$R.sql -d tpch_parquet_20gpn_snappy_part_random_gpadmin
done