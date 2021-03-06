
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
limit_cpu integer,
limit_mem integer,
limit_storage integer,
req_cpu integer,
req_mem integer,
req_storage integer,
PRIMARY KEY (pod_name, ip, exp_time));

-- exp_queries table represents every query runned in hawq
create table if not exists exp_queries(
    query_id varchar(32),
    cluster cidr,
    query_plan json,
    start_time timestamp with time zone,
    end_time timestamp with time zone,
   -- query_plan_rows integer,
   -- total_exec_time_in_ms float,
    success boolean default TRUE,
    PRIMARY KEY (query_id, cluster));
    -- config_id integer references exp_config(id)

-- prometheus metrics logs
create table if not exists k8s_prometheus_metrics (
    sample_time timestamp with time zone, 
    k8s_namespace varchar(64), 
    metrics_value float, 
    job varchar(64), 
    pod_name varchar(64), 
    metrics_name varchar(64), 
    full_name varchar(128),
    container_name varchar(64), 
    cpu varchar(16), 
    device varchar(64), 
    scope varchar(32),
    pg_type varchar(32),
    io_os varchar(32), 
    instance_name varchar(128), 
    ds_ready boolean, 
    io_arch varchar(32), 
    io_hostname varchar(64), 
    role_in_master varchar(32)
);

CREATE FUNCTION k8s_prometheus_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER k8s_prometheus_insert_trigger
    BEFORE INSERT ON k8s_prometheus_metrics
    FOR EACH ROW EXECUTE PROCEDURE k8s_prometheus_insert_trigger();
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

-- create table if not exists query_segment_rel (
--     hawq_query_id varchar(32) PRIMARY KEY,
--     pod_name varchar(64)[]
-- );

-- samples table
create table if not exists query_samples (
    query_id varchar(32),
    cluster cidr,
    pod_ips cidr[],
    o_segment_number integer,
    o_segment_cpu_limit integer,
    o_segment_cpu_req integer,
    o_segment_mem_limit integer,
    o_segment_mem_req integer,
    o_segment_storage_limit integer,
    o_segment_storage_req integer,
    i_cpu_usage_max integer,
    i_mem_usage_max integer,
    o_exec_time float,
    error_msg text,
    PRIMARY KEY (query_id, cluster));

create table if not exists query_samples_host_ver (
    query_id varchar(32),
    cluster cidr,
    pod_hosts varchar(32)[],
    o_segment_number integer,
    o_segment_cpu_limit integer,
    o_segment_cpu_req integer,
    o_segment_mem_limit integer,
    o_segment_mem_req integer,
    o_segment_storage_limit integer,
    o_segment_storage_req integer,
    i_cpu_usage_max integer,
    i_mem_usage_max integer,
    o_exec_time float,
    error_msg text,
    PRIMARY KEY (query_id, cluster));
create table if not exists group_configs(
    config_time timestamp with time zone,
    group_name varchar(32),
    cpu_limit integer,
    mem_limit integer,
    storage_limit integer,
    PRIMARY KEY (config_time, group_name));