
-- exp_config of the running query
create table if not exists exp_config(
    id SERIAL PRIMARY KEY, 
    group_size integer, 
    cpu_size_req integer, cpu_size_max integer, mem_size_req integer, mem_size_max integer, storage_size_req integer, storage_size_max integer);

-- exp_segments_info segment info for segment and ip
create table if not exists exp_segments_info
(pod_name varchar(64), host_name varchar(64), 
exp_time timestamp with time zone, 
ip cidr, 
config_id integer references exp_config(id));

-- exp_queries table represents every query runned in hawq
create table if not exists exp_queries(
    query_id varchar(32),
    query_plan_hash varchar(64),
    start_time timestamp with time zone,
    end_time timestamp with time zone,
    query_plan_rows integer,
    total_exec_time_in_ms float,
    success boolean default TRUE,
    config_id integer references exp_config(id),
    PRIMARY KEY (query_id, config_id));

-- prometheus metrics logs
create table if not exists k8s_prometheus_metrics (
    whole_name varchar(128), 
    sample_time timestamp with time zone, 
    k8s_namespace varchar(64), 
    metrics_value float, 
    job varchar(64), 
    pod_name varchar(64), 
    container_name varchar(64), 
    metrics_name varchar(64), 
    io_os varchar(32), 
    instance_name varchar(128), 
    failure_region varchar(32), 
    failure_zone varchar(32), 
    node_pool varchar(64), 
    ds_ready boolean, 
    io_arch varchar(32), 
    instance_type varchar(32), 
    io_hostname varchar(64), 
    cpu varchar(16), 
    device varchar(64), 
    pg_type varchar(32),
    scope varchar(32)
);

-- plan info 
create table if not exists query_plan_info (
    query_plan_hash varchar(64),
    query_plan_op_list text[],
    query_plan_table_name text[],
    query_plan_db varchar(128),
    PRIMARY KEY (query_plan_hash, query_plan_db));
-- query table info statistic info from database
create table if not exists query_table_info (
    query_db_size integer,
    query_table_name varchar(128),
    query_table_size real,
    PRIMARY KEY (query_db_size, query_table_name));

create table if not exists query_segment_rel (
    config_id integer,
    hawq_query_id varchar(32),
    pod_name varchar(64)[]
);