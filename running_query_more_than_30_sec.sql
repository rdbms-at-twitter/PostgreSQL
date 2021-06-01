select datname, pid, usename, application_name, query
from pg_stat_activity where (now() - xact_start)::interval > '30 sec'::interval;
