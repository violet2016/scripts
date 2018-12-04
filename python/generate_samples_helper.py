import db_config
import json
from datetime import datetime
import psycopg2

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
            try:
                if query_info['cluster'] is not None:
                    insert_query_sql = 'insert into exp_queries (query_id, cluster) values (\'%s\', \'%s\')' % (query_id, query_info['cluster'])
                    cur.execute(insert_query_sql)
                exec_time = calc_time_delta(query_info['start_time'], query_info['end_time'])
                if query_info['start_time'] is not None:
                    update_query_sql = 'update exp_queries set start_time = timestamp with time zone \'%s\' where query_id = \'%s\'' % (query_info['start_time'], query_id)
                    cur.execute(update_query_sql)
                if query_info['end_time'] is not None:
                    update_query_sql = 'update exp_queries set end_time = timestamp with time zone \'%s\' where query_id = \'%s\'' % (query_info['end_time'], query_id)
                    cur.execute(update_query_sql)
                if query_info['plan'] is not None:
                    update_query_sql = 'update exp_queries set query_plan = \'%s\' where query_id = \'%s\'' % (json.dumps(query_info['plan']), query_id)
                    cur.execute(update_query_sql)
                list_string = ', '.join(query_info['list'])
                sample_sql = 'insert into query_samples (query_id, cluster, pod_ips, o_segment_number, o_exec_time) values (\'%s\', \'%s\', \'{%s}\', %s, %s)' % (query_id, query_info['cluster'], list_string, len(query_info['list']), exec_time)
                
                cur.execute(sample_sql)
                db_connection.commit()
            except (Exception, psycopg2.DatabaseError) as error:
                print('error happened', error)
                cur.rollback()
                continue
            except:
                continue

def update_segment_config(all_lists, db_connection):
    with db_connection.cursor() as cur:
        for pod_name, pod_info in all_lists.items():
            try:
                insert_query = 'insert into exp_segments_info (pod_name, host_name, exp_time, ip, limit_cpu, limit_mem, limit_storage, req_cpu, req_mem, req_storage) values (\'%s\',\'%s\', CURRENT_TIMESTAMP, \'%s\', %s, %s, %s, %s, %s, %s)' % (pod_name, pod_info['hostname'], pod_info['ip'], pod_info['limit_cpu'], pod_info['limit_mem'], pod_info['limit_storage'], pod_info['req_cpu'], pod_info['req_mem'], pod_info['req_storage'])
                cur.execute(insert_query)
                db_connection.commit()
            except:
                continue

# def update_query_sample_resource_usage(db_connection):
#     # TODO group name make not be fixed to start with group
#     sql = "update query_samples set cpu_percent_list = t2.cpu_percent_list, \
#     From (select array_agg(percent) as cpu_percent_list, total_exec_time_in_ms, config_id, query_id  \
#            from (
#             select metrics_name, q.query_id,
#             cast(100000 as decimal)* (max(metrics_value)-min(metrics_value))/(extract('epoch' from q.end_time)  - extract('epoch' from q.start_time) ) as cpu_max, 
#             k.pod_name from k8s_prometheus_metrics k, exp_queries q 
#             where sample_time > q.start_time and sample_time < q.end_time and  
#             metrics_name = 'container_cpu_user_seconds_total' and metrics_value > 0 and k.pod_name like 'group%%'
#             group by k.pod_name, metrics_name, q.end_time, q.start_time, q.query_id
#             ) as t1 where case when total_exec_time_in_ms < 15000 then true else t1.percent > 1  end group by total_exec_time_in_ms, config_id, query_id) as t2
# WHERE query_samples.query_id= t2.query_id
#         ;
# "