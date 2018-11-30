import sys
import re
import yaml
from generate_samples_helper import update_segment_config
import db_config
def get_segment_list(ip_filename, yaml_file):
    pod_list = {}
    with open(ip_filename, "r") as ip_file, open(yaml_file, "r") as yaml_file:
        next(ip_file)
        for line in ip_file:
            pod = line.split()
            pod_list[pod[0]] = {'ip': pod[5], 'hostname':pod[6]}
        pod_name_reg = r'^(.*?)-\d*$'
        group_config = yaml.load(yaml_file)
        groups = group_config['Spec']['Groups']
        for name in pod_list.keys():
            m0 = re.search(pod_name_reg, name)
            if m0 is not None:
                pod_list[name]['group'] = m0.group(1)
                pod_list[name]['limit_cpu'] = groups['Group Resource Limit']['Cpu']
                pod_list[name]['limit_mem'] = groups['Group Resource Limit']['Memory']
                pod_list[name]['limit_storage'] = groups['Group Resource Limit']['Ephemeral Storage']
                req_name = 'Group Resource Limit'
                try:
                    if groups['Group Resource Request'] is not None:
                        req_name = 'Group Resource Request'
                except:
                    print("no limit in", name)
                pod_list[name]['req_cpu'] = groups[req_name]['Cpu']
                pod_list[name]['req_mem'] = groups[req_name]['Memory']
                pod_list[name]['req_storage'] = groups[req_name]['Ephemeral Storage']
    return pod_list
if __name__ == '__main__':
    ip_file = sys.argv[1]
    yaml_file = sys.argv[2]
    pod_list = get_segment_list(ip_file, yaml_file)
    update_segment_config(pod_list, db_config.myConnection)
    