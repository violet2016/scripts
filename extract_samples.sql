create table if not exists query_samples (
    query_id integer,
    config_id integer,
    o_segment_number integer,
    o_cpu_usage_max integer,
    o_mem_usage_max integer,
    o_point float,
    i_plan_rows integer,
    i_plan_ops integer[],
    i_plan_op_nums integer[],
    i_tables varchar(128)[],
    i_tables_size real[],
    i_columns_name varchar(128)[],
    i_columns_type varchar(32)[],
    i_columns_op integer[],
    o_exec_time float,
)
-- SELECT 
--   nspname AS schemaname,relname,reltuples
-- FROM pg_class C
-- LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
-- WHERE 
--   nspname NOT IN ('pg_catalog', 'information_schema') AND
--   relkind='r' 
-- ORDER BY reltuples DESC;