-- done
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
