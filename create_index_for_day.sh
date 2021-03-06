#!/bin/bash
DATE_TODAY=`date '+%Y-%m-%d'` 
DATE_TOMORROW=`date -d '+1 day' '+%Y-%m-%d'` 
DATE_INSQL_N=`date -d '+2 day' '+%Y-%m-%d'`
DATE_INNAME_TODAY=`date '+%Y_%m_%d'` 
DATE_INNAME=`date -d '+1 day' '+%Y_%m_%d'` 
echo "create table"
psql -d hawq-recommend -c  "create table k8s_prometheus_metrics_d_$DATE_INNAME
    (check (sample_time >= date '$DATE_TOMORROW' and sample_time <= date '$DATE_INSQL_N'))
    inherits (k8s_prometheus_metrics);"
echo "create index"
psql -d hawq-recommend -c "
create index k8s_prometheus_metrics_sample_time_$DATE_INNAME on k8s_prometheus_metrics using btree (sample_time);
CREATE OR REPLACE FUNCTION k8s_prometheus_insert_trigger()
RETURNS TRIGGER AS \$\$
BEGIN
    IF ( NEW.sample_time >= DATE '$DATE_TODAY' AND
         NEW.sample_time < DATE '$DATE_TOMORROW' ) THEN
        INSERT INTO k8s_prometheus_metrics_d_$DATE_INNAME_TODAY VALUES (NEW.*);
    ELSIF ( NEW.sample_time >= DATE '$DATE_TOMORROW' AND
            NEW.sample_time < DATE '$DATE_INSQL_N' ) THEN
        INSERT INTO k8s_prometheus_metrics_d_$DATE_INNAME  VALUES (NEW.*);
    ELSE
        RAISE EXCEPTION 'Date out of range.  Fix the k8s_prometheus_insert_trigger() function!';
    END IF;
    RETURN NULL;
END;
\$\$
LANGUAGE plpgsql;"
