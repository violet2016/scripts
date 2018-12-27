import yaml
import sys, os
import db_config
from datetime import datetime


def read_hawq_group_def_yaml(config_file):
    configs = []
    with open(config_file, 'r') as stream:
        data_loaded = yaml.load(stream)
        #for p in data_loaded['items']:
        for g in data_loaded['spec']['groups']:
            config = {}
            config['name'] = g['name']
            config['cpu'] = g['groupResourceLimit']['cpu']
            config['storage'] = g['groupResourceLimit']['ephemeralStorage']
            config['memory'] = g['groupResourceLimit']['memory']
            configs.append(config)
    return configs

def config_to_database(configs, time, db_connection):
    if len(configs) == 0:
        return False
    with db_connection.cursor() as cur:
        value_string = []
        for c in configs:
            value = "('%s', '%s', %s, %s, %s)" % (time, c['name'], c['cpu'], c['memory'], c['storage'])
            value_string.append(value)
        sql = "insert into group_configs values%s" % (','.join(value_string))
        cur.execute(sql)
        db_connection.commit()
    return True
if __name__ == '__main__':
    config_file = sys.argv[1]
    timestamp = os.stat(config_file).st_mtime
    timestr = datetime.utcfromtimestamp(timestamp).strftime('%Y-%m-%d %H:%M:%SZ')
    configs = read_hawq_group_def_yaml(config_file)
    config_to_database(configs, timestr, db_config.myConnection)
    db_config.myConnection.close()