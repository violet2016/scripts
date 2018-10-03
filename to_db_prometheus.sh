psql -d hawq-recommend -f create_prometheus.sql
cp $1/prometheus.csv $1/prometheus-origin.csv
sed -i '' '/scrape/d' $1/prometheus.csv
sed -i '' '/,linux,/d' $1/prometheus.csv
psql -d hawq-recommend -c "copy k8s_prometheus_metrics from '$1/prometheus.csv' CSV HEADER"