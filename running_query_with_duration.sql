select pid,query_start,state,application_name,datname,left(query,60),(now() - xact_start)::interval from pg_stat_activity order by query_start asc limit 10;
