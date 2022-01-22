### This repository is used for gathering useful scripts for managing PostgreSQL.

#### Usefull Site
https://wiki.postgresql.org/wiki/Disk_Usage/ja

#### パラメータの説明
https://pgtune.leopard.in.ua/#/

#### メモリーなどのパラメータ設定の参考値(実際の処理内容や接続数によります）
https://pgtune.leopard.in.ua/#/

#### 良く使うコマンド



- Promptの設定

```
-bash-4.2$ psql app  -P pager=off -c "\d"
         List of relations
 Schema |  Name  | Type  |  Owner   
--------+--------+-------+----------
 public | t_post | table | app_user
(1 row)


-bash-4.2$ psql app 
psql (9.2.24)
Type "help" for help.

app=# \pset pager off
Pager usage is off.
app=# \timing
Timing is on.
app=# select now();
              now              
-------------------------------
 2020-05-29 22:13:15.775279+00
(1 row)

Time: 0.351 ms
app=# 

```



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

app=# insert into memo(id,data,data2) values(generate_series(1,20000),'Fragment','Confirmation');

app=# analyze verbose memo;
INFO:  "public.memo"を解析しています
INFO:  "memo": 636ページの内636をスキャン。86410の有効な行と3の不要な行が存在。30000行をサンプリング。推定総行数は86410
ANALYZE
app=# 


```

- EXPLAIN(シークエンシャルスキャンのコスト)

```
app=# select name,setting,category from pg_settings where name like '%cost';
          name           | setting |                   category                    
-------------------------+---------+-----------------------------------------------
 cpu_index_tuple_cost    | 0.005   | 問い合わせのチューニング / プランナコスト定数
 cpu_operator_cost       | 0.0025  | 問い合わせのチューニング / プランナコスト定数
 cpu_tuple_cost          | 0.01    | 問い合わせのチューニング / プランナコスト定数
 jit_above_cost          | 100000  | 問い合わせのチューニング / プランナコスト定数
 jit_inline_above_cost   | 500000  | 問い合わせのチューニング / プランナコスト定数
 jit_optimize_above_cost | 500000  | 問い合わせのチューニング / プランナコスト定数
 parallel_setup_cost     | 1000    | 問い合わせのチューニング / プランナコスト定数
 parallel_tuple_cost     | 0.1     | 問い合わせのチューニング / プランナコスト定数
 random_page_cost        | 4       | 問い合わせのチューニング / プランナコスト定数
 seq_page_cost           | 1       | 問い合わせのチューニング / プランナコスト定数
(10 行)

app=# select relname,relpages,reltuples from pg_class where relname = 'memo';
 relname | relpages | reltuples 
---------+----------+-----------
 memo    |      148 |     20000
(1 行)

app=# explain select * from memo;
                        QUERY PLAN                         
-----------------------------------------------------------
 Seq Scan on memo  (cost=0.00..348.00 rows=20000 width=26)
(1 行)

app=# select (1 * 148) + (0.01 * 20000) "シークエンシャルスキャンのコスト(seq_page_cost * relpages) + (cpu_tuple_cost * reltuples)";

シークエンシャルスキャンのコスト(seq_page_cost * relpages) + (cpu_tuple_cost * reltuples)
-------------------------------------------------
                                          348.00
(1 行)

```

- How to Check Buffer Pool

```
postgres=# create extension pg_buffercache;
CREATE EXTENSION


postgres=# \c development
You are now connected to database "development" as user "postgres".
taskleaf_development=# \d
                        List of relations
 Schema |               Name                |   Type   |  Owner   
--------+-----------------------------------+----------+----------
 public | active_storage_attachments        | table    | api
 public | active_storage_attachments_id_seq | sequence | api
 public | active_storage_blobs              | table    | api
 public | active_storage_blobs_id_seq       | sequence | api
 public | ar_internal_metadata              | table    | api
 public | kb                                | table    | api
 public | kb_id_seq                         | sequence | api
 public | pg_buffercache                    | view     | postgres
 public | schema_migrations                 | table    | api

(13 rows)

```

reference: https://www.postgresql.org/docs/13/pgbuffercache.html

## FTS for speed up text document Search

```
development-# CREATE EXTENSION pg_bigm;
CREATE EXTENSION
development=# \d tasks;
                                      Table "public.tasks"
   Column    |            Type             |                     Modifiers                      
-------------+-----------------------------+----------------------------------------------------
 id          | bigint                      | not null default nextval('tasks_id_seq'::regclass)
 name        | character varying(100)      | not null
 description | text                        | 
 created_at  | timestamp without time zone | not null
 updated_at  | timestamp without time zone | not null
 user_id     | bigint                      | not null
Indexes:
    "tasks_pkey" PRIMARY KEY, btree (id)
    "index_tasks_on_user_id" btree (user_id)


development=# explain select count(*) from tasks where description like '%ダンプ%';
                         QUERY PLAN                         
------------------------------------------------------------
 Aggregate  (cost=28.49..28.50 rows=1 width=0)
   ->  Seq Scan on tasks  (cost=0.00..28.49 rows=1 width=0)
         Filter: (description ~~ '%ダンプ%'::text)
(3 rows)

development=# create index idx_bigram_task_description on tasks using gin (description gin_bigm_ops);
CREATE INDEX


development=# \d tasks;
                                      Table "public.tasks"
   Column    |            Type             |                     Modifiers                      
-------------+-----------------------------+----------------------------------------------------
 id          | bigint                      | not null default nextval('tasks_id_seq'::regclass)
 name        | character varying(100)      | not null
 description | text                        | 
 created_at  | timestamp without time zone | not null
 updated_at  | timestamp without time zone | not null
 user_id     | bigint                      | not null
Indexes:
    "tasks_pkey" PRIMARY KEY, btree (id)
    "idx_bigram_task_description" gin (description gin_bigm_ops)
    "index_tasks_on_user_id" btree (user_id)

development=# explain select count(*) from tasks where description like '%ダンプ%';
                                           QUERY PLAN                                            
-------------------------------------------------------------------------------------------------
 Aggregate  (cost=24.02..24.03 rows=1 width=0)
   ->  Bitmap Heap Scan on tasks  (cost=20.00..24.01 rows=1 width=0)
         Recheck Cond: (description ~~ '%ダンプ%'::text)
         ->  Bitmap Index Scan on idx_bigram_task_description  (cost=0.00..20.00 rows=1 width=0)
               Index Cond: (description ~~ '%ダンプ%'::text)
(5 rows)

development=# 

```
