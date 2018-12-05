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
                db_connection.rollback()
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
def concat_surround_with_quotes(strings):
    result = ', '.join('\'' + item + '\'' for item in strings)
    return result

def update_query_sample_resource_usage(db_connection, id, start_time, end_time):
    # TODO group name make not be fixed to start with group
    with db_connection.cursor() as cur:
        ips_sql = "select pod_ips from query_samples where query_id = '%s'" % (id)
        cur.execute(ips_sql)
        rows = cur.fetchall()
        if rows is None or len(rows) == 0:
            return
        pods_ips = rows[0][0]
        ips = concat_surround_with_quotes(pods_ips)
        pod_names_sql = "select pod_name from ( \
            select distinct ON (pod_name) * from exp_segments_info where exp_time < '%s' and exp_time >= timestamp'%s' - interval '1h') \
            as sub where ip in (%s) order by exp_time desc" % (start_time, start_time, ips)
        cur.execute(pod_names_sql)
        rows = cur.fetchall()
        pod_names = []
        if rows is None or len(rows) == len(pods_ips):
            return
        for r in rows:
            pod_names.append(r[0])
        pod_name_list_string = concat_surround_with_quotes(pod_names)
        
        metrics_name_list = ['container_cpu_user_seconds_total', 'container_cpu_system_seconds_total']
        metrics_name_string = concat_surround_with_quotes(metrics_name_list)
        get_diff_metrics_sql = "select metrics_name, max(metric_diff) as diff \
                                from ( \
                                select k.metrics_name,\
                                (max(k.metrics_value)-min(k.metrics_value)) as metric_diff, \
                                k.pod_name from k8s_prometheus_metrics k \
                                where sample_time > '%s' and sample_time < '%s' and metrics_name in (%s) and pod_name in (%s) and \
                                metrics_value > 0 and k.pod_name like 'group%%' and container_name not in ('','POD') \
                                group by k.pod_name, k.metrics_name \
                                ) as t1 group by metrics_name \
                                ) as t2" % (start_time, end_time, pod_name_list_string, metrics_name_string)
        cur.execute(get_diff_metrics_sql)
        rows = cur.fetchall()
        cpu_user = None
        cpu_system = None
        for r in rows:
            if r[0] == 'container_cpu_user_seconds_total':
                cpu_user = r[1]
            elif r[0] == 'container_cpu_system_seconds_total':
                cpu_system = r[1]
        update_sql = "update query_samples set i_cpu_usage_max = %s" % (cpu_user+cpu_system)
        print(update_sql)
        cur.execute(update_sql)
        db_connection.commit()
    
if __name__ == '__main__':
    update_query_sample_resource_usage(db_config.myConnection, 'qid-850328167', '2018-12-05 05:46:31+00', '2018-12-05 05:48:49+00')