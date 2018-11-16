#!/bin/bash
kubectl get hawqresourcepool -o yaml > config.yaml
if [ $# -ne 4 ]; then
    echo -e "\nUsage:\t $0 HOSTNAME START END REPEAT_TIME\n"
    exit 1
fi
DIFF=$(($3-$2+1))
RANDOM=$$
for i in `seq $4`
do
    R=$(($(($RANDOM%$DIFF))+$2))
    echo $R
    new_name=`printf "./tpch_sqls/%0.2i.sql\n" $R`
    psql -h $1 -U gpadmin -f $new_name -d tpch_parquet_20gpn_snappy_part_random_gpadmin
done
