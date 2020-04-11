### This repository is used for gathering useful scripts for managing PostgreSQL.

#### Usefull Site
https://wiki.postgresql.org/wiki/Disk_Usage/ja

#### 良く使うコマンド

- 処理中Processの確認

```
app=# select * from pg_stat_activity where pid = 2039;
-[ RECORD 1 ]----+------------------------------
datid            | 
datname          | 
pid              | 2039
usesysid         | 57347
usename          | replication_user
application_name | walreceiver
client_addr      | 192.168.56.112
client_hostname  | 
client_port      | 54408
backend_start    | 2020-04-11 17:53:23.836423+09     #プロセス起動時刻
xact_start       | 　　　　　　　　　　　　　　　　　#トランザクション開始時刻
query_start      |                                   #クエリーを発行した時刻
state_change     | 2020-04-11 17:53:23.984009+09
wait_event_type  | Activity
wait_event       | WalSenderMain                     #処理待ちのステータス（何を待っているか）
state            | active
backend_xid      |                                   #プロセスの状態（Active＝実行中)
backend_xmin     | 
query            |                                   #最後に実行したクエリー
backend_type     | walsender

app=# 

```

- Lock PIDの確認

```
app=# select lock.locktype,class.relname,lock.pid,lock.mode from pg_locks lock
left outer join pg_stat_activity act on lock.pid = act.pid left outer join
pg_class class on lock.relation = class.oid where not lock.granted
order by lock.pid;
-[ RECORD 1 ]-----------
locktype | transactionid
relname  | 
pid      | 3377    /*** 他の処理のCommitを待っているPID ***/
mode     | ShareLock
-[ RECORD 2 ]-----------
locktype | tuple
relname  | memo
pid      | 3713    /*** 3377を待っている為XロックになっているPID ***/
mode     | ExclusiveLock


```


- 自分のPIDを確認

```
app=# select pg_backend_pid();
 pg_backend_pid 
----------------
           3375```

```



