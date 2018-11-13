#!/bin/bash
rm -rf test_result
mkdir test_result
set -e
if [ "$2" -eq "1" ]; then
for filepath in ./tpch_sqls/*.sql
do
    filename=$(basename $filepath)
    echo "psql -f $filepath -d tpch_parquet_$1gpn_snappy_part_random_gpadmin > test_result/result_test_$filename.txt"
    echo `date '+StartTime:%Y-%m-%d %H:%M:%S'` >> test_result/result_test_$filename.txt
    #psql -f $filepath -d tpch_parquet_$1gpn_snappy_part_random_gpadmin >> test_result/result_test_$filename.txt
    ./run_sql.sh $1 $filepath $filename
    echo `date '+EndTime:%Y-%m-%d %H:%M:%S'` >> test_result/result_test_$filename.txt
done
fi
if [ "$2" -eq "2" ];then
for filepath in ./tpch_sqls_explain/*.sql
do
    filename=$(basename $filepath)
        echo "$filepath"
        psql -f $filepath -d tpch_parquet_$1gpn_snappy_part_random_gpadmin > test_result/plan_$filename.txt
        sleep 5
done
fi