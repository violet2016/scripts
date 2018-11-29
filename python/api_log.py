import sys
import re
import csv
import os
import subprocess
import fnmatch
import db_config
import json
from generate_samples_helper import *
def parse_node_info(node_info):
    # Gather Motion  (cost=1726765.38..1726765.44 rows=25 width=136)\n
    node_regex = r'^(.*?)\W*\(cost=([\d\.]+?)\.\.([\d\.]+?)\W+rows=(\d*?)\W+width=(\d*?)\)'
    m0 = re.search(node_regex, node_info)
    if m0 is None:
        print("Cannot match node info", node_info)
        return {}
    n = {'name':m0.group(1) , 'min_cost': m0.group(2), 'max_cost': m0.group(3), 'rows': m0.group(4), 'width': m0.group(5)}
    return n
def visit_all_plan(node):
    if node is not None:
        for child in node.keys():
            if child == 'Node Info':
                node[child] = parse_node_info(node[child])
            else:
                node[child] = visit_all_plan(node[child])
    return node

def plan_to_json(plan):
    j0 = json.loads(plan)
    j = json.loads(j0)
    root = j['PLAN']
    j['PLAN'] = visit_all_plan(root)
   
    return j

def append_seg_list(all_lists, row):
    is_req, is_start = False, False
    #alloc_reg = r'^alloc successfully: .*segmentList\[(.*)\]'
    request_reg = r'^alloc request input:query_info:<cluster:\\"(.*?)\\" queryid:\\"(qid-\d*)\\" > resource_info:<seg_num:(\d*) max_seg_num:(\d*) plan_info:(.*) >\W*$'
    alloc_reg = r'^alloc successfully: queryid\[(qid-\d*)\] resource\[(.*?)\] .*segmentList\[(.*?)\]'
    release_reg = r'query\[(qid-\d*)\] release resource\[(.*?)\]'
    seg_list = []
    query_id = None
    start_time = None
    end_time = None
    resource_id = None
    cluster = None
    min_seg, max_seg = None, None
    plan = None
    for i in range(len(row)):
        if i == 0:
            m0 = re.search(request_reg, row[i])
            if m0 is not None:
                cluster = m0.group(1)
                query_id = m0.group(2)
                min_seg = m0.group(3)
                max_seg = m0.group(4)
                plan = plan_to_json(m0.group(5))
                is_req = True
                is_start = False
                continue
            m1 = re.search(alloc_reg, row[i])
            if m1 is not None: 
                query_id = m1.group(1)
                resource_id = m1.group(2)
                seg_list = m1.group(3).split(',')
                is_req = False
                is_start = True
                continue
            m2 = re.search(release_reg, row[i])
            if m2 is not None: 
                query_id = m2.group(1)
                resource_id = m2.group(2)
                is_start = False
                is_req = False
                continue
        else:
            m = re.search(r'^\d\d\d\d\-\d\d\-\d\dT', row[i])
            if m is not None:
                if is_start:
                    start_time = row[i]
                else:
                    end_time = row[i]
    if query_id is not None and query_id not in all_lists.keys():
        all_lists[query_id] = {'start_time': None, 'end_time': None}
    if is_req:
        all_lists[query_id]['plan'] = plan
        all_lists[query_id]['max_seg'] = max_seg
        all_lists[query_id]['min_seg'] = min_seg
        all_lists[query_id]['cluster'] = cluster
    elif is_start:
        all_lists[query_id]['list'] = seg_list
        all_lists[query_id]['start_time'] = start_time
        all_lists[query_id]['resource_id'] = resource_id
    elif query_id is not None:
        all_lists[query_id]['end_time'] = end_time


if __name__ == '__main__':
    api_file = sys.argv[1]
    all_lists = {}
    with open(api_file, mode='r') as csvfile:
        spamreader = csv.reader(csvfile, delimiter=',')
        for row in spamreader:
            append_seg_list(all_lists, row)
        print(all_lists)
        create_new_query_sample(all_lists, db_config.myConnection)
        #insert into query and samples
