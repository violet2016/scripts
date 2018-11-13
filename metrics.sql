select  query_plan_rows, c.cpu_size, c.mem_size, c.storage_size, c.data_size,
                query_plan_op_list, 
                table_size_list , cpu_percent_list, label_time, c.group_size, c.id
                from samples left join exp_config c on config_id = c.id where is_test = false and config_id = 126 and total_exec_time_in_ms is not NULL;


select metrics_name, min(metrics_value), pod_name from k8s_prometheus_metrics, exp_queries q where sample_time > q.start_time and sample_time < q.end_time and q.config_id=66 and q.query_id=1 and metrics_name In ( 'container_cpu_user_seconds_total') and metrics_value > 0 and pod_name like 'group1%' group by pod_name, metrics_name;

select count(distinct pod_name) from k8s_prometheus_metrics, exp_queries q where sample_time > q.start_time and sample_time < q.end_time and q.config_id=66 and q.query_id=1 and metrics_name In ( 'container_cpu_user_seconds_total') and metrics_value > 0 and pod_name like 'group1%';


select count(*) from (
select metrics_name, max(metrics_value)-min(metrics_value) as diff, pod_name from k8s_prometheus_metrics, exp_queries q where sample_time > q.start_time and sample_time < q.end_time and q.config_id=25 and q.query_id=1 and metrics_name In ( 'container_cpu_user_seconds_total') and metrics_value > 0 and pod_name like 'group1%'  group by pod_name, metrics_name) as t1 where t1.diff > 1
;

select avg(percent), max(percent) from (
select metrics_name, (cast(100000 as decimal) /  c.cpu_size) * (max(metrics_value)-min(metrics_value))/(extract('epoch' from q.end_time)  - extract('epoch' from q.start_time) ) as percent, pod_name from k8s_prometheus_metrics, exp_queries q left join exp_config c on q.config_id = c.id where q.config_id=25 and q.query_id=1 and sample_time > q.start_time and sample_time < q.end_time and metrics_name = 'container_cpu_user_seconds_total' and metrics_value > 0 and pod_name like 'group1%' and container_name='group1' group by pod_name, metrics_name, q.start_time, q.end_time, c.cpu_size) as t1 where t1.percent > 1;

select metrics_name,  (max(metrics_value)-min(metrics_value))/(extract('epoch' from q.end_time)  - extract('epoch' from q.start_time) ) as percent, pod_name from k8s_prometheus_metrics, exp_queries q left join exp_config c on q.config_id = c.id where q.config_id=25 and q.query_id=1 and sample_time > q.start_time and sample_time < q.end_time and metrics_name = 'container_cpu_user_seconds_total' and metrics_value > 0 and pod_name like 'group1%'  group by pod_name, metrics_name, q.start_time, q.end_time, c.cpu_size;


select metrics_name, max(metrics_value), min(metrics_value), pod_name from k8s_prometheus_metrics, exp_queries q where sample_time > q.start_time and sample_time < q.end_time and q.config_id=26 and q.query_id=21 and metrics_name In ( 'container_memory_working_set_bytes') and metrics_value > 0 and pod_name like 'group1%'  group by pod_name, metrics_name;
select max(v) from(
select q.query_id, metrics_name, max(metrics_value)- min(metrics_value) as v, pod_name from k8s_prometheus_metrics, exp_queries q where sample_time > q.start_time and sample_time < q.end_time and q.config_id=244 and  metrics_name In ( 'container_memory_working_set_bytes') and metrics_value > 0 and pod_name like 'group1%'  group by pod_name, metrics_name, q.query_id) as t group by query_id, metrics_name order by query_id;

select max(metrics_value), q.query_id, pod_name from k8s_prometheus_metrics, exp_queries q where sample_time > q.start_time and sample_time < q.end_time and q.config_id=55 and metrics_name In ( 'container_memory_usage_bytes') and metrics_value > 0 and pod_name like 'group1%' and container_name='group1' group by pod_name, metrics_name, q.query_id;

select percent from (
            select metrics_name, (cast(100000 as decimal) /  c.cpu_size) * (max(metrics_value)-min(metrics_value))/(extract('epoch' from q.end_time)  - extract('epoch' from q.start_time) ) as percent, 
            k.pod_name from k8s_prometheus_metrics k, exp_queries q 
            left join query_segment_rel r on q.config_id = r.config_id
            left join exp_config c on q.config_id = c.id
            where q.config_id=26 and q.query_id=16 and 
            CASE WHEN r.pod_name is not NULL THEN k.pod_name=r.pod_name ELSE true END
            and sample_time > q.start_time and sample_time < q.end_time and  
            metrics_name = 'container_cpu_user_seconds_total' and metrics_value > 0 and k.pod_name like 'group1%%' and container_name='group1' 
            group by k.pod_name, metrics_name, c.cpu_size, q.end_time, q.start_time
            ) as t1 where t1.percent > 1;


create table samples as (
select  e.query_plan_rows, c.cpu_size, c.mem_size, c.storage_size, c.data_size,
                i.query_plan_op_list, 
                array_agg(t.query_table_size) , e.query_id, e.config_id
                from exp_queries e  
                inner  join exp_config c on e.config_id=c.id 
                inner join query_plan_info i on e.query_plan_hash = i.query_plan_hash 
	            inner join query_table_info t on t.query_db_size = c.data_size and t.query_table_name= ANY(i.query_plan_table_name) 
                Group by e.query_id, e.config_id, e.query_plan_rows, c.cpu_size, c.mem_size, c.storage_size, c.data_size, i.query_plan_op_list);
ALTER TABLE samples ADD COLUMN IF NOT EXISTS cpu_percent_list decimal[];
ALTER TABLE samples ADD COLUMN IF NOT EXISTS total_exec_time_in_ms decimal;

update query_plan_info set query_plan_table_name = t.tables From
(select tables, hash from tmp_plan) t where query_plan_info.query_plan_hash = t.hash;

update samples set cpu_percent_list = t2.cpu_percent_list,
    total_exec_time_in_ms = t2.total_exec_time_in_ms

    From (select array_agg(percent) as cpu_percent_list, total_exec_time_in_ms, config_id, query_id         from (
            select metrics_name, total_exec_time_in_ms, q.config_id, q.query_id,
            (cast(100000 as decimal) /  c.cpu_size) * (max(metrics_value)-min(metrics_value))/(extract('epoch' from q.end_time)  - extract('epoch' from q.start_time) ) as percent, 
            k.pod_name from k8s_prometheus_metrics k, exp_queries q 
            left join exp_config c on q.config_id = c.id
            where sample_time > q.start_time and sample_time < q.end_time and  
            metrics_name = 'container_cpu_user_seconds_total' and metrics_value > 0 and k.pod_name like 'group1%%' and container_name='group1' 
            group by k.pod_name, metrics_name, c.cpu_size, q.end_time, q.start_time, total_exec_time_in_ms, q.config_id, q.query_id
            ) as t1 where case when total_exec_time_in_ms < 15000 then true else t1.percent > 1  end group by total_exec_time_in_ms, config_id, query_id) as t2
WHERE samples.config_id = t2.config_id and samples.query_id= t2.query_id
        ;

ALTER TABLE samples ADD COLUMN IF NOT EXISTS label_time decimal;
ALTER TABLE samples ADD COLUMN IF NOT EXISTS label_cpu_usage decimal;
ALTER TABLE samples ADD COLUMN IF NOT EXISTS is_test BOOLEAN default false;
ALTER TABLE samples ADD COLUMN IF NOT EXISTS is_success BOOLEAN default true;
create table avg_exec_time (query_id integer, data_size integer, avg_exec_time decimal, PRIMARY KEY (query_id, data_size));
insert into avg_exec_time  (query_id, data_size, avg_exec_time)
        select query_id, data_size, avg(total_exec_time_in_ms) as avg_time from samples where total_exec_time_in_ms is not NULL and total_exec_time_in_ms != 0 group by query_id, data_size;

update  avg_exec_time  set avg_exec_time = t.avg_time from
        (select query_id, data_size, avg(total_exec_time_in_ms) as avg_time from samples where total_exec_time_in_ms is not NULL and total_exec_time_in_ms != 0 group by query_id, data_size) as t
where avg_exec_time.query_id=t.query_id and avg_exec_time.data_size=t.data_size;

alter table avg_exec_time add column IF NOT EXISTS avg_cpu_time decimal;
update avg_exec_time s set avg_cpu_time = t.avg_cpu_time
from (select query_id, data_size, avg(total_exec_time_in_ms * cpu_size*array_length(cpu_percent_list, 1)) as avg_cpu_time from samples where total_exec_time_in_ms is not NULL and total_exec_time_in_ms != 0 group by query_id, data_size) as t where s.query_id = t.query_id and s.data_size = t.data_size;

update samples s set label_time = (t.avg_exec_time - total_exec_time_in_ms)/t.avg_exec_time From (select avg_exec_time, query_id, data_size from avg_exec_time) as t where total_exec_time_in_ms is not NULL and total_exec_time_in_ms != 0 and s.query_id = t.query_id and s.data_size = t.data_size;

ALTER TABLE samples ADD COLUMN IF NOT EXISTS label_cpu_time decimal;
update samples s set label_cpu_time = (t.avg_cpu_time - total_exec_time_in_ms*cpu_size*array_length(cpu_percent_list, 1))/t.avg_cpu_time From (select avg_cpu_time, query_id, data_size from avg_exec_time) as t where total_exec_time_in_ms is not NULL and total_exec_time_in_ms != 0 and s.query_id = t.query_id and s.data_size = t.data_size;

update samples s set is_test = true where total_exec_time_in_ms is NULL;

update samples set table_size_list = t2.tables
                from (
                        select array_agg(t.query_table_size) as tables, e.config_id, e.query_id from exp_queries e  
                inner  join exp_config c on e.config_id=c.id 
                inner join query_plan_info i on e.query_plan_hash = i.query_plan_hash 
	        inner join query_table_info t on t.query_db_size = c.data_size and t.query_table_name= ANY(i.query_plan_table_name) Group by e.query_id, e.config_id) t2 where t2.config_id = samples.config_id and t2.query_id = samples.query_id;
select subt.qid, subt.cid, size_list, table_list from (
select query.query_id qid, query.config_id cid, samples.table_size_list size_list,i.query_plan_table_name table_list, array_length(samples.table_size_list, 1) ts, array_length(i.query_plan_table_name, 1) tn from samples left join exp_queries query on samples.query_id = query.query_id and samples.config_id = query.config_id
left join query_plan_info i on i.query_plan_hash = query.query_plan_hash) subt where subt.ts != subt.tn;            
                --Group by e.query_id, e.config_id, e.query_plan_rows, c.cpu_size, c.mem_size, c.storage_size, c.data_size, i.query_plan_op_list

update exp_queries set query_plan_hash = t.query_plan_hash, query_plan_rows = t.query_plan_rows from (
        select query_plan_hash, query_plan_rows ,query_id from exp_queries where config_id = 122
) t where exp_queries.query_id = t.query_id and exp_queries.config_id > 122;
update exp_queries set query_plan_rows = t.query_plan_rows from (
        select query_plan_rows ,query_id, query_plan_hash from exp_queries
) t where exp_queries.query_id = t.query_id and exp_queries.query_plan_hash = t.query_plan_hash and config_id > 122;

update samples set query_plan_rows = t.query_plan_rows from (
        select query_plan_rows ,query_id, config_id from exp_queries
) t where samples.query_id = t.query_id and samples.config_id = t.config_id and samples.config_id > 122;

alter table samples add column if not exists recommend_level integer;

select query_id, min(total_exec_time_in_ms) from (
select query_id, array_length(cpu_percent_list, 1), label_time, config_id, total_exec_time_in_ms, c.group_size, c.cpu_size, c.mem_size, c.data_size from samples left join exp_config c on config_id = c.id  where total_exec_time_in_ms > 0) t
group by t.query_id order by t.query_id;



select max(v) from(                                                                                                                                                                                                   select q.query_id, metrics_name, max(metrics_value)- min(metrics_value) as v, pod_name from k8s_prometheus_metrics, exp_queries q where sample_time > q.start_time and sample_time < q.end_time and q.config_id=38 and  metrics_name In ( 'container_memory_working_set_bytes') and metrics_value > 0 and pod_name like 'group1%'  group by pod_name, metrics_name, q.query_id) as t where query_id in(21) group by query_id, metrics_name  order by query_id;
select * from exp_config where group_size=25 and cpu_size = 1500 and mem_size = 1500;
select max(v) from (select query_id, unnest(cpu_percent_list) v from samples where config_id=35 order by query_id) t group by query_id order by query_id;
select max(v) from (select query_id, unnest(cpu_percent_list) v from samples where config_id=38 order by query_id) t where query_id in (21) group by query_id order by query_id;
select query_id,count(*) from query_segment_rel left join exp_config c on c.id = config_id where c.group_size=15 and c.cpu_size=2000 and c.mem_size =1000 group by query_id ,config_id order by query_id;