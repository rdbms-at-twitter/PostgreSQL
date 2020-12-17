select query_start,state,application_name,left(query,60) from pg_stat_activity where query <> '<insufficient privilege>' limit  10;
