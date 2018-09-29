with diff_cpu as (
    select metrics_name, container_name, pod_name, metrics_value, sample_time, metrics_value - lag(metrics_value) over (partition BY pod_name order by pod_name, sample_time) as cpu from raw_result_0920_1
    where metrics_name like '%cpu_usage%' and pod_name like 'group1%' and container_name = 'group1'
)

select r.metrics_name, r.container_name, r.pod_name, res.start_time, res.end_time, 100*sum(cpu)/datediff('second', res.start_time, res.end_time) from diff_cpu r, test_0920_1_time as res where sample_time > res.start_time and sample_time < res.end_time and res.id = 3 group by r.metrics_name, r.container_name, r.pod_name, res.start_time, res.end_time;

-- with diff_mem as (
--     select metrics_name, container_name, pod_name, sample_time, metrics_value as mem_rss from raw_result_0920_1
--     where metrics_name='container_memory_working_set_bytes' and pod_name like 'group1%' and container_name = 'group1'
-- )
-- select r.metrics_name, r.container_name, r.pod_name, res.start_time, res.end_time, max(r.mem_rss) from diff_mem r, test_0920_1_time as res where sample_time > res.start_time and sample_time < res.end_time and res.id = 2 group by r.metrics_name, r.container_name, r.pod_name, res.start_time, res.end_time;

-- container_memory_rss
-- container_memory_swap
-- container_memory_usage_bytes
-- container_memory_working_set_bytes
-- memory_cache
-- memory_failures_total
-- memory_max_usage_bytes

-- cpu_cfs_periods_total
-- cpu_cfs_throttled_periods_total
-- cpu_cfs_throttled_seconds_total
-- cpu_user_seconds_totafs_usage_bytes
-- cpu_system_seconds_total
-- cpu_usage_seconds_total
-- cpu_user_seconds_total

-- fs_usage_bytes


-- select metrics_name, container_name, pod_name, metrics_value, sample_time from raw_result_0920_1, test_0920_1_time as res where metrics_name='container_memory_rss' and pod_name like 'group1%' and container_name = 'group1' and sample_time > res.start_time and sample_time < res.end_time and res.id = 3 order by pod_name, sample_time;