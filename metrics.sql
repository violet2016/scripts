select metrics_name, min(metrics_value), pod_name from k8s_prometheus_metrics, exp_queries q where sample_time > q.start_time and sample_time < q.end_time and q.config_id=66 and q.query_id=1 and metrics_name In ( 'container_cpu_user_seconds_total') and metrics_value > 0 and pod_name like 'group1%' group by pod_name, metrics_name;

select count(distinct pod_name) from k8s_prometheus_metrics, exp_queries q where sample_time > q.start_time and sample_time < q.end_time and q.config_id=66 and q.query_id=1 and metrics_name In ( 'container_cpu_user_seconds_total') and metrics_value > 0 and pod_name like 'group1%';


select count(*) from (
select metrics_name, max(metrics_value)-min(metrics_value) as diff, pod_name from k8s_prometheus_metrics, exp_queries q where sample_time > q.start_time and sample_time < q.end_time and q.config_id=26 and q.query_id=16 and metrics_name In ( 'container_cpu_user_seconds_total') and metrics_value > 0 and pod_name like 'group1%'  group by pod_name, metrics_name) as t1 where t1.diff > 1
;