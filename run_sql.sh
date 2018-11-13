#!/bin/bash
set -e
psql -f $2 -d tpch_parquet_$1gpn_snappy_part_random_gpadmin >> test_result/result_test_$3.txt