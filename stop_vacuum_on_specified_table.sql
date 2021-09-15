app=# SELECT relname, reloptions FROM pg_class WHERE relname='t_post';
-[ RECORD 1 ]------------------------------------------------------------
relname    | t_post
reloptions | {autovacuum_vacuum_scale_factor=0.1,autovacuum_enabled=true}

app=# alter table t_post set (autovacuum_enabled = false);
ALTER TABLE

app=# SELECT relname, reloptions FROM pg_class WHERE relname='t_post';
-[ RECORD 1 ]-------------------------------------------------------------
relname    | t_post
reloptions | {autovacuum_vacuum_scale_factor=0.1,autovacuum_enabled=false}

app=# 
