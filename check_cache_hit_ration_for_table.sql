select (heap_blks_hit*100.0)/(heap_blks_hit+heap_blks_read) from pg_statio_user_tables where relname = 'memo';
