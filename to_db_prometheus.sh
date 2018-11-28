# put the prometheus csv file into database
#
#!/bin/bash
if [[ "$OSTYPE" == "darwin"* ]]; then
	sed -i '' '/scrape/d' $1
	sed -i '' '/,linux,/d' $1
else
	sed -i '/scrape/d' $1
	sed -i '/,linux,/d' $1
fi
header=`python ./python/prometheus_csv_header.py $1` 
psql -d hawq-recommend -c "copy k8s_prometheus_metrics($header) from '$1' CSV HEADER"
