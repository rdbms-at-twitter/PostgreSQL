#!/bin/bash

value1=`psql -t -A -c 'select count(*) from pg_stat_activity;'`
echo $value1
echo "[$[value1]]"
