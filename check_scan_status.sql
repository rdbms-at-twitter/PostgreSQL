select relname, seq_scan, seq_tup_read,seq_tup_read/seq_scan as tup_per_read  from pg_stat_user_tables where seq_scan > 0 order by tup_per_read desc;
