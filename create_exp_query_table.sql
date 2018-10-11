create table if not exists exp_queries(
    query_id integer,
    query_plan_hash varchar(64),
    start_time timestamp with time zone,
    end_time timestamp with time zone,
    query_plan_rows integer,
    total_exec_time_in_ms float,
    config_id integer references exp_config(id),
    PRIMARY KEY (query_id, config_id));

ALTER TABLE exp_queries ADD COLUMN IF NOT EXISTS success BOOLEAN DEFAULT TRUE;