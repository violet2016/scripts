--done
create table if not exists exp_config(
    id SERIAL PRIMARY KEY, 
    exp_time timestamp with time zone, 
    group_size integer, 
    cpu_size integer, mem_size integer, storage_size integer, data_size integer);
create table if not exists exp_segments_info
(pod_name varchar(64), host_name varchar(64), 
exp_time timestamp with time zone, 
ip cidr, 
config_id integer references exp_config(id));