update  avg_exec_time  set avg_exec_time = t.avg_time from
        (select query_id, data_size, min(total_exec_time_in_ms) + (max(total_exec_time_in_ms) - min(total_exec_time_in_ms))/4 as avg_time from samples where total_exec_time_in_ms is not NULL and total_exec_time_in_ms != 0 group by query_id, data_size) as t
where avg_exec_time.query_id=t.query_id and avg_exec_time.data_size=t.data_size;

update samples s set label_time = (t.avg_exec_time - total_exec_time_in_ms)/t.avg_exec_time From (select avg_exec_time, query_id, data_size from avg_exec_time) as t where total_exec_time_in_ms is not NULL and total_exec_time_in_ms != 0 and s.query_id = t.query_id and s.data_size = t.data_size;






select metrics_name, total_exec_time_in_ms, q.config_id, q.query_id,
            (cast(100000 as decimal) /  c.cpu_size) * (max(metrics_value)-min(metrics_value))/(extract('epoch' from q.end_time)  - extract('epoch' from q.start_time) ) as percent, 
            k.pod_name from k8s_prometheus_metrics k, exp_queries q 
            left join exp_config c on q.config_id = c.id 
            where config_id = 34 and query_id = 1 and sample_time > q.start_time and sample_time < q.end_time and 
            metrics_name = 'container_cpu_user_seconds_total' and metrics_value > 0 and k.pod_name like 'group1%%' and container_name='group1' 
            group by k.pod_name, metrics_name, c.cpu_size, q.end_time, q.start_time, total_exec_time_in_ms, q.config_id, q.query_id;
select id from exp_config where group_size = 35 and cpu_size =  2000 and mem_size = 2000;

select count(*),query_id from (
select metrics_name, total_exec_time_in_ms, q.config_id, q.query_id,
             (max(metrics_value)-min(metrics_value)) as mem, 
            k.pod_name from k8s_prometheus_metrics k, exp_queries q 
            left join exp_config c on q.config_id = c.id 
            where config_id = 2 and sample_time > q.start_time and sample_time < q.end_time and 
            metrics_name = 'container_memory_usage_bytes' and metrics_value > 0 and k.pod_name like 'group1%%' and container_name='group1' 
            group by k.pod_name, metrics_name, c.cpu_size, q.end_time, q.start_time, total_exec_time_in_ms, q.config_id, q.query_id
) t where t.mem > 0 group by query_id order by query_id;


select metrics_name, total_exec_time_in_ms, q.config_id, q.query_id,
             max(metrics_value) as mem, 
            k.pod_name from k8s_prometheus_metrics k, exp_queries q 
            left join exp_config c on q.config_id = c.id 
            where config_id = 194 and query_id = 5 and sample_time > q.start_time and sample_time < q.end_time and 
            metrics_name = 'container_memory_usage_bytes' and metrics_value > 0 and k.pod_name like 'group1%%' and container_name='group1' 
            group by k.pod_name, metrics_name, c.cpu_size, q.end_time, q.start_time, total_exec_time_in_ms, q.config_id, q.query_id