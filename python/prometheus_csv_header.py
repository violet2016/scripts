import csv
import sys

def get_header(prom_file):
    f = open(prom_file, 'rb')
    reader = csv.reader(f)
    headers = next(reader, None)
    name_map = {'timestamp': 'sample_time', 'namespace':'k8s_namespace', 'value':'metrics_value', 'job':'', 'pod_name':'', '__name__':'metrics_name', 'name':'full_name', 'container_name':'', 'beta_kubernetes_io_os':'io_os', 'instance':'instance_name', 'beta_kubernetes_io_fluentd_ds_ready':'ds_ready', 'beta_kubernetes_io_arch':'io_arch', 'kubernetes_io_hostname':'io_hostname', 'cpu':'', 'device':'', 'scope':'', 'type':'pg_type', 'node_role_kubernetes_io_master':'role_in_master'}
    mapped_headers = []
    for h in headers:
        if name_map[h] != '':
            mapped_headers.append(name_map[h])
        else:
            mapped_headers.append(h)
    return mapped_headers

if __name__ == '__main__':
    prom_file = sys.argv[1]
    header = get_header(prom_file)
    str_list = ",".join(header)
    print(str_list)