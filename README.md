### This repository is used for gathering useful scripts for managing PostgreSQL.

#### Usefull Site
https://wiki.postgresql.org/wiki/Disk_Usage/ja

#### 良く使うコマンド

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

