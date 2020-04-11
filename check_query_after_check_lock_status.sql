SELECT pid, datname,query_start, substr(query, 0, 50),wait_event_type,state FROM pg_stat_activity  ORDER BY query_start;
