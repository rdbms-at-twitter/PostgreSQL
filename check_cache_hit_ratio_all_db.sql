select datname,
round(blks_hit*100/(blks_hit+blks_read), 2) as cache_hit_ratio
from pg_stat_database where blks_read > 0;
