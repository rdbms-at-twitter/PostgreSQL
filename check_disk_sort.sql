select datname, temp_files, pg_size_pretty(temp_bytes) as temp_bytes, pg_size_pretty(round(temp_bytes/temp_files,2)) as temp_file_size
from pg_stat_database where temp_files > 0;
