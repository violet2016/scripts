sed -i '' '/scrape/d' prometheus.csv
sed -i '' '/,linux,/d' prometheus.csv
psql -d hawq-recommend -c "copy k8s_prometheus_metrics from './prometheus.csv' CSV HEADER"
rm prometheus.csv