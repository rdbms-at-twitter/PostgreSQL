select (blks_hit * 100.0)/(blks_hit + blks_read) from pg_stat_database where datname = 'app';
