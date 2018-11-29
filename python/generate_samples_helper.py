import db_config
import json
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
        return timedelta.total_seconds()
    return 0
def create_new_query_sample(all_lists, db_connection):
    with db_connection.cursor() as cur:
         for query_id, query_info in all_lists.items():
            exec_time = calc_time_delta(query_info['start_time'], query_info['end_time'])
            insert_query_sql = 'insert into exp_queries (query_id) values (\'%s\')' % (query_id)
            cur.execute(insert_query_sql)
            if query_info['start_time'] is not None:
                update_query_sql = 'update exp_queries set start_time = timestamp with time zone \'%s\' where query_id = \'%s\'' % (query_info['start_time'], query_id)
                cur.execute(update_query_sql)
            if query_info['end_time'] is not None:
                update_query_sql = 'update exp_queries set end_time = timestamp with time zone \'%s\' where query_id = \'%s\'' % (query_info['end_time'], query_id)
                cur.execute(update_query_sql)
            if query_info['plan'] is not None:
                update_query_sql = 'update exp_queries set query_plan = \'%s\' where query_id = \'%s\'' % (json.dumps(query_info['plan']), query_id)
                cur.execute(update_query_sql)
            list_string = ', '.join('\'{0}\''.format(w) for w in query_info['list'])
            sample_sql = 'insert into query_samples (query_id, pod_ips, o_segment_number, o_exec_time) values (\'%s\', \'{%s}\' %s, %s)' % (query_id, list_string, len(query_info['list']), exec_time)
            
            cur.execute(sample_sql)
            db_connection.commit()