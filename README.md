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


/*** 上記の例だとPID3375のトランザクションがまだCommitされていない為Lockが発生していることが確認出来る ***/

app=# SELECT pid, datname,query_start, substr(query, 0, 50),wait_event_type,state FROM pg_stat_activity  ORDER BY query_start;
 pid  | datname |          query_start          |                      substr                       | wait_event_type |        state        
------+---------+-------------------------------+---------------------------------------------------+-----------------+---------------------
 3375 | app     | 2020-04-11 20:04:56.542219+09 | update memo set data = pg_backend_pid() where id  | Client          | idle in transaction
 3377 | app     | 2020-04-11 20:05:01.342127+09 | update memo set data = pg_backend_pid() where id  | Lock            | active
 3713 | app     | 2020-04-11 20:05:06.666111+09 | update memo set data = pg_backend_pid() where id  | Lock            | active
 2154 | app     | 2020-04-11 20:05:17.885617+09 | SELECT pid, datname,query_start, substr(query, 0, |                 | active
 2030 |         |                               |                                                   | Activity        | 


```

- Lock PIDの確認（PostgreSQL9.6以降)

```
app=# select lock.locktype,class.relname,lock.pid,lock.mode from pg_locks lock
left outer join pg_stat_activity act on lock.pid = act.pid left outer join
pg_class class on lock.relation = class.oid where not lock.granted
order by lock.pid;
   locktype    | relname | pid  |     mode      
---------------+---------+------+---------------
 transactionid |         | 3377 | ShareLock
 tuple         | memo    | 3713 | ExclusiveLock
(2 行)

app=# select  pg_blocking_pids(3377);
 pg_blocking_pids 
------------------
 {3375}
(1 行)

app=# select  pg_blocking_pids(3713);
 pg_blocking_pids 
------------------
 {3377}
(1 行)

```





- 自分のPIDを確認

```
app=# select pg_backend_pid();
 pg_backend_pid 
----------------
           3375

```


- 統計情報の更新(通常はAUTO VACUUMで自動的に統計も更新される)
```

app=# SELECT relpages, reltuples, reltuples/relpages as pagedata
FROM pg_class WHERE relname = 'memo';
 relpages | reltuples |      pagedata      
----------+-----------+--------------------
       11 |      1406 | 127.81818181818181
(1 行)

app=# insert into memo(id,data,data2) values(generate_series(2000,10000),'Fragment','Confirmation');
INSERT 0 8001
app=# SELECT relpages, reltuples, reltuples/relpages as pagedata
FROM pg_class WHERE relname = 'memo';
 relpages | reltuples |      pagedata      
----------+-----------+--------------------
       11 |      1406 | 127.81818181818181
(1 行)


app=# analyze memo;
ANALYZE
app=# SELECT relpages, reltuples, reltuples/relpages as pagedata
FROM pg_class WHERE relname = 'memo';
 relpages | reltuples |      pagedata      
----------+-----------+--------------------
       70 |      9407 | 134.38571428571427
(1 行)

app=# 


```
