create table if not exists query_plan_info (
    query_id integer,
    query_plan_hash varchar(64),
    query_plan_op_list text[],
    query_plan_table_name text[],
    query_plan_db varchar(128),
    PRIMARY KEY (query_plan_hash, query_plan_db));

create table if not exists query_table_info (
    query_db_size integer,
    query_table_name varchar(128),
    query_table_size real,
    PRIMARY KEY (query_db_size, query_table_name));