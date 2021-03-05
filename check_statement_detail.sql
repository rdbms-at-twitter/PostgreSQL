## 1) postgresql.conf
#  shared_preload_libraries = 'pg_stat_statements'
#  pg_stat_statements.max = 10000
#  pg_stat_statements.track = all
#
# 2) restart pg
#  
# 3) CREATE EXTENSION pg_stat_statements;
#
# memo: select pg_stat_statements_reset();
################################################


SELECT query, calls, total_time, rows, 100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0) AS hit_percent
FROM pg_stat_statements ORDER BY total_time DESC LIMIT 5;
