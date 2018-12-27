#!/bin/bash
#kubectl get hawqresourcepool -o yaml > config.yaml

if [ $# -ne 6 ]; then
    echo -e "\nUsage:\t $0 HOSTNAME START END REPEAT_TIME DATA_SIZE\n"
    exit 1
fi
configs=$(python36 extract_config_yaml.py get $6)
echo $configs
DIFF=$(($3-$2+1))
RANDOM=$$
for i in `seq $4`
do
    R=$(($(($RANDOM%$DIFF))+$2))
    echo $R
    new_name=`printf "./tpch_sqls/%0.2i.sql\n" $R`
    command="psql -h $1 -U gpadmin -f $new_name -d tpch_parquet_$5gpn_snappy_part_random_gpadmin >> ./sql.log 2>&1"
    echo "$command\n"

    psql -h $1 -U gpadmin -f $new_name -d tpch_parquet_$5gpn_snappy_part_random_gpadmin >> ./sql.log 2>&1
    sleep 5
done
