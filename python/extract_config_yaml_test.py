import unittest
from unittest.mock import patch
import os
from extract_config_yaml import *

class read_hawq_group_def_yaml_test(unittest.TestCase):
    def test_single_pool(self):
        config_file = './test_data_files/config.yaml'
        configs = read_hawq_group_def_yaml(config_file)
        self.assertEqual(len(configs), 2)
        self.assertEqual(configs[1]['memory'], 2048)

class config_to_databse_test(unittest.TestCase):
    @patch("psycopg2.connect")
    def test_write_config_to_db(self, mock_connect):
        expected = [['fake', 'row', 1], ['fake', 'row', 2]]
        configs = [{'name': 'group1', 'cpu': 500, 'storage': 1024, 'memory': 1024},{'name': 'group2', 'cpu': 500, 'storage': 2048, 'memory': 2048}]
        mock_connect.return_value.cursor.return_value.fetchall.return_value = expected
        result = config_to_database(configs, mock_connect)
        self.assertEqual(result, True)


if __name__ == '__main__':
    unittest.main()