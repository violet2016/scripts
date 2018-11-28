import unittest
from api_log import *

class api_log_test(unittest.TestCase):
    def test_api_log_parsing(self):
        all_lists = {}
        with open("./test_data_files/api-log-0.csv", mode='r') as csvfile:
            spamreader = csv.reader(csvfile, delimiter=',')
            for row in spamreader:
                append_seg_list(all_lists, row)
        self.assertEqual(len(all_lists), 29)
        self.assertEqual(all_lists['qid-1176932765']['start_time'], '2018-11-27T05:42:36Z')
        self.assertEqual(len(all_lists['qid-1176932765']['list']), 1)
        self.assertNotEqual(len(all_lists['qid-1176932765']['plan']), 0)

class plan_test(unittest.TestCase):
    def test_plan_to_json(self):
        test_string = '\"{ \\\"TYPE\\\": \\\"Select\\\", \\\"rows\\\": 25.000000, \\\"width\\\": 136, \\\"PLAN\\\": { \\\"Node Info\\\": \\\"Gather Motion  (cost=1726765.38..1726765.44 rows=25 width=136)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"Sort  (cost=1726765.38..1726765.44 rows=25 width=136)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"HashAggregate  (cost=1726764.49..1726764.80 rows=25 width=136)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"Redistribute Motion  (cost=1726763.42..1726764.11 rows=25 width=136)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"HashAggregate  (cost=1726763.42..1726763.61 rows=25 width=136)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"Hash Join  (cost=265739.34..1705107.91 rows=4331103 width=61)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"Hash Join  (cost=47239.00..1197619.65 rows=23148764 width=44)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"Parquet table Scan  (cost=0.00..513789.64 rows=23148764 width=44)\\\\n\\\" }, \\\"Right Tree\\\": { \\\"Node Info\\\": \\\"Hash  (cost=24739.00..24739.00 rows=1800000 width=8)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"Broadcast Motion  (cost=0.00..24739.00 rows=1800000 width=8)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"Parquet table Scan  (cost=0.00..3739.00 rows=300000 width=8)\\\\n\\\" } } } }, \\\"Right Tree\\\": { \\\"Node Info\\\": \\\"Hash  (cost=201661.46..201661.46 rows=1122592 width=45)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"Broadcast Motion  (cost=20287.67..201661.46 rows=1122592 width=45)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"Hash Join  (cost=20287.67..188564.55 rows=187099 width=45)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"Redistribute Motion  (cost=0.00..165796.82 rows=56533 width=12)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"Parquet table Scan  (cost=0.00..164666.17 rows=56533 width=12)\\\\n\\\" } }, \\\"Right Tree\\\": { \\\"Node Info\\\": \\\"Hash  (cost=20246.30..20246.30 rows=3310 width=41)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"Redistribute Motion  (cost=3.37..20246.30 rows=3310 width=41)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"Hash Join  (cost=3.37..20180.11 rows=3310 width=41)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"Parquet table Scan  (cost=0.00..18439.20 rows=661920 width=8)\\\\n\\\" }, \\\"Right Tree\\\": { \\\"Node Info\\\": \\\"Hash  (cost=3.00..3.00 rows=31 width=33)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"Broadcast Motion  (cost=1.21..3.00 rows=31 width=33)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"Hash Join  (cost=1.21..2.65 rows=6 width=33)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"Parquet table Scan  (cost=0.00..1.25 rows=25 width=37)\\\\n\\\" }, \\\"Right Tree\\\": { \\\"Node Info\\\": \\\"Hash  (cost=1.13..1.13 rows=7 width=4)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"Broadcast Motion  (cost=0.00..1.13 rows=7 width=4)\\\\n\\\", \\\"Left Tree\\\": { \\\"Node Info\\\": \\\"Parquet table Scan  (cost=0.00..1.06 rows=2 width=4)\\\\n\\\" } } } } } } }} } } } } } } } } } } }\"'
        j = plan_to_json(test_string)
        self.assertEqual(j['TYPE'], 'Select')
        self.assertEqual(j['PLAN']['Node Info']['name'], 'Gather Motion')

if __name__ == '__main__':
    unittest.main()