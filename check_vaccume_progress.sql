select
  v.pid,
  v.datname,
  c.relname,
  v.phase,
  v.heap_blks_total,
  v.heap_blks_scanned,
  v.heap_blks_vacuumed,
  v.index_vacuum_count,
  v.max_dead_tuples,
  v.num_dead_tuples
from
  pg_stat_progress_vacuum as v
join
  pg_class as c
on v.relid = c.relfilenode;
