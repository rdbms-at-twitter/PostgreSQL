select datname, pid, usename, application_name, xact_start,(now() - xact_start)::interval(3) as duration, query
from pg_stat_activity where (now() - xact_start)::interval > '30 sec'::interval;
