#!/bin/bash
mkdir test_result
for filepath in ./tpch_sqls/*
do
    filename=$(basename $filepath)
    psql -f $filepath -d tpch_parquet_$1gpn_snappy_part_random_gpadmin > test_result/result_test_$filename.txt
done
