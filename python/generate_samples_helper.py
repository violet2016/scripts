import db_config
from datetime import datetime


def query_segment_info(all_lists, db_connection):
    with db_connection.cursor() as cur:
        for key, value in all_lists.items():
            splitted_list = value['list']
            find_segment_name_by_ip_sql = "select pod_name from exp_segments_info where ip in ('%s')" % "', '".join(splitted_list)
            cur.execute(find_segment_name_by_ip_sql)
            rows = cur.fetchall()
            for row in rows:
                command = "insert into  query_segment_rel (config_id, query_id,hawq_query_id,pod_name) values ( %s, \'%s\', \'%s\')" % (key, value['resource_id'], row[0])
                cur.execute(command)

def calc_time_delta(start, end):
    time_format = '%Y-%m-%dT%H:%M:%SZ'
    if start is not None and end is not None:
        start_time = datetime.strptime(start, time_format)
        end_time = datetime.strptime(end, time_format)
        timedelta = end_time - start_time
        return timedelta.second
    return 0
def create_new_query_sample(all_lists, db_connection):
    with db_connection.cursor() as cur:
         for query_id, query_info in all_lists.items():
            exec_time = calc_time_delta(query_info['start_time'], query_info['end_time'])
            insert_query_sql = 'insert into exp_queries (query_id, start_time, end_time) values ( \
                \'%s\', timestamp with time zone \'%s\',timestamp with time zone \'%s\' )\
                ' % (query_id, query_info['start_time'], query_info['end_time'])
            sample_sql = 'insert into samples (query_id, o_segment_number, o_exec_time) values (\'%s\', %s, %s)' % (query_id, len(query_info['list']), exec_time)
            cur.execute(insert_query_sql)
            cur.execute(sample_sql)