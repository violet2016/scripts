if [[ "$OSTYPE" == "darwin"* ]]; then
	sed -i '' '/scrape/d' $1
	sed -i '' '/,linux,/d' $1
else
	sed -i '/scrape/d' $1
	sed -i '/,linux,/d' $1
fi
psql -d hawq-recommend -c "copy k8s_prometheus_metrics from '$1' CSV HEADER"
