psql -d hawq-recommend -c "update exp_queries set query_plan_hash = t.query_plan_hash, query_plan_rows = t.query_plan_rows from (
        select query_plan_hash, query_plan_rows ,query_id from exp_queries where config_id = 122
) t where exp_queries.query_id = t.query_id and exp_queries.config_id > $1;"

psql -d hawq-recommend -c "
insert into samples (query_plan_rows ,cpu_size ,mem_size ,storage_size, data_size ,  query_plan_op_list  ,  table_size_list   ,query_id ,config_id, total_exec_time_in_ms)
       select e.query_plan_rows, c.cpu_size, c.mem_size, c.storage_size, c.data_size,
                i.query_plan_op_list, 
                array_agg(t.query_table_size) , e.query_id, e.config_id, e.total_exec_time_in_ms
                from exp_queries e 
                inner  join exp_config c on e.config_id=c.id 
                inner join query_plan_info i on e.query_plan_hash = i.query_plan_hash 
	            inner join query_table_info t on t.query_db_size = c.data_size and t.query_table_name= ANY(i.query_plan_table_name)  where e.config_id > $1
                Group by e.query_id, e.config_id, e.query_plan_rows, c.cpu_size, c.mem_size, c.storage_size, c.data_size, i.query_plan_op_list;
        "
psql -d hawq-recommend -c "
update samples set cpu_percent_list = t2.cpu_percent_list,
    total_exec_time_in_ms = t2.total_exec_time_in_ms, is_test=true

    From (select array_agg(percent) as cpu_percent_list, total_exec_time_in_ms, config_id, query_id         from (
            select metrics_name, total_exec_time_in_ms, q.config_id, q.query_id,
            (cast(100000 as decimal) /  c.cpu_size) * (max(metrics_value)-min(metrics_value))/(extract('epoch' from q.end_time)  - extract('epoch' from q.start_time) ) as percent, 
            k.pod_name from k8s_prometheus_metrics k, exp_queries q 
            left join exp_config c on q.config_id = c.id
            where sample_time > q.start_time and sample_time < q.end_time and  
            metrics_name = 'container_cpu_user_seconds_total' and metrics_value > 0 and k.pod_name like 'group1%%' and container_name='group1' 
            group by k.pod_name, metrics_name, c.cpu_size, q.end_time, q.start_time, total_exec_time_in_ms, q.config_id, q.query_id
            ) as t1 where case when total_exec_time_in_ms < 15000 then true else t1.percent > 1  end group by total_exec_time_in_ms, config_id, query_id) as t2
WHERE samples.config_id > $1 and samples.config_id = t2.config_id and samples.query_id= t2.query_id
        ;
"
psql -d hawq-recommend -c "
update samples s set label_time = (t.avg_exec_time - total_exec_time_in_ms)/t.avg_exec_time From (select avg_exec_time, query_id, data_size from avg_exec_time) as t where total_exec_time_in_ms is not NULL and total_exec_time_in_ms != 0 and s.query_id = t.query_id and s.data_size = t.data_size and s.config_id > $1;"
psql -d hawq-recommend -c "
update samples s set label_time = -100  where total_exec_time_in_ms = 0 and s.config_id > $1;"

#psql -d hawq-recommend -c "
#update samples s set recommend_level = case when total_exec_time_in_ms > t.avg_exec_time From (select #avg_exec_time, query_id, data_size from avg_exec_time) as t where total_exec_time_in_ms is not NULL #and total_exec_time_in_ms != 0 and s.query_id = t.query_id and s.data_size = t.data_size and #s.config_id > $1;"

# select  query_plan_rows, cpu_size, mem_size, storage_size, data_size,
#                 query_plan_op_list, 
#                 table_size_list , cpu_percent_list, total_exec_time_in_ms
#                 from samples where is_test = true and config_id >= 120 and total_exec_time_in_ms is not NULL