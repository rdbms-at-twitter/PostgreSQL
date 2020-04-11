select lock.locktype,class.relname,lock.pid,lock.mode from pg_locks lock
left outer join pg_stat_activity act on lock.pid = act.pid left outer join
pg_class class on lock.relation = class.oid where not lock.granted
order by lock.pid;

