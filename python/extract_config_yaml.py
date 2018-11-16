import yaml
import sys
import db_config

def read_hawq_group_def_yaml(config_file):
    configs = []
    with open(config_file, 'r') as stream:
        data_loaded = yaml.load(stream)
        for p in data_loaded['items']:
            for g in p['spec']['groups']:
                config = {}
                config['name'] = g['name']
                config['cpu'] = g['groupResourceLimit']['cpu']
                config['storage'] = g['groupResourceLimit']['ephemeralStorage']
                config['memory'] = g['groupResourceLimit']['memory']
                configs.append(config)
    return configs

def config_to_database(configs, db_connection):
    if len(configs) == 0:
        return False
    with db_connection.cursor() as cur:
        value_string = []
        for c in configs:
            value = "(%s, %s, %s, %s)" % (c['name'], c['cpu'], c['memory'], c['storage'])
            value_string.append(value)
        sql = "insert into group_configs values%s" % (','.join(value_string))
        print(sql)
        cur.execute(sql)
    return True

if __name__ == '__main__':
    config_file = sys.argv[1]
    configs = read_hawq_group_def_yaml(config_file)
    config_to_database(configs, db_config.myConnection)
    db_config.myConnection.close()