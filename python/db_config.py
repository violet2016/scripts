import psycopg2
hostname = 'localhost'
username = 'vcheng'
database = 'hawq-recommend'
myConnection = psycopg2.connect( host=hostname, user=username, dbname=database )