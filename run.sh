#!/bin/bash
rm -rf test_result
mkdir test_result
for filepath in ./tpch_sqls/*.sql
do
    filename=$(basename $filepath)
    echo "psql -f $filepath -d tpch_parquet_$1gpn_snappy_part_random_gpadmin > test_result/result_test_$filename.txt"
    echo `date '+StartTime:%Y-%m-%d %H:%M:%S'` >> test_result/result_test_$filename.txt
    psql -f $filepath -d tpch_parquet_$1gpn_snappy_part_random_gpadmin >> test_result/result_test_$filename.txt
    echo `date '+EndTime:%Y-%m-%d %H:%M:%S'` >> test_result/result_test_$filename.txt
done

for filepath in ./tpch_sqls_explain/*.sql
do
    filename=$(basename $filepath)
    psql -f $filepath -d tpch_parquet_$1gpn_snappy_part_random_gpadmin > test_result/plan_$filename.txt
done
