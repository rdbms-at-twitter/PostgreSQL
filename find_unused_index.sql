SELECT s.relname AS table_name,
       indexrelname AS index_name,
       CASE WHEN i.indisunique THEN 'Y'
       ELSE 'N'
       END AS unique,
       idx_scan AS index_scans,
       idx_scan AS idx_tup_read,
       idx_scan AS idx_tup_fetch,
       pg_size_pretty(pg_relation_size(quote_ident(s.indexrelname)::text)) AS index_size
FROM   pg_catalog.pg_stat_user_indexes s,
       pg_index i
WHERE  i.indexrelid = s.indexrelid
       and s.idx_scan = 0
       and s.idx_tup_read = 0
       and s.idx_tup_fetch = 0
       and i.indisunique <> 'y' --ignore pk and uk;
