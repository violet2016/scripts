create table if not exists query_plan_info (
    query_plan_hash varchar(64),
    query_plan_length integer,
    gather_motion_num integer,
)