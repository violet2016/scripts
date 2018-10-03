create table if not exists exp_queries(
    query_id integer,
    query_plan_rows integer,
    query_plan_hash varchar(64),
    start_time timestamp with time zone,
    end_time timestamp with time zone,
    total_exec_time_in_ms float,
    config_id integer references exp_config(id));