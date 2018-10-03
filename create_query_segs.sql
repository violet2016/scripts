create table if not exists query_segment_rel (
    query_id integer,
    config_id integer,
    hawq_query_id varchar(32),
    pod_name varchar(64)
);