##########　テスト用テーブル作成


testdb=> CREATE SEQUENCE aurora_test_id START 1;
CREATE SEQUENCE
testdb=> create table aurora_test (id integer DEFAULT nextval('aurora_test_id'),memo varchar (100));
CREATE TABLE
testdb=> ALTER TABLE aurora_test add column created timestamp default CURRENT_TIMESTAMP;
ALTER TABLE
testdb=> \d aurora_test;
                                     Table "public.aurora_test"
 Column  |            Type             | Collation | Nullable |               Default
---------+-----------------------------+-----------+----------+-------------------------------------
 id      | integer                     |           |          | nextval('aurora_test_id'::regclass)
 memo    | character varying(100)      |           |          |
 created | timestamp without time zone |           |          | CURRENT_TIMESTAMP

testdb=>



########## テストINSERT LOOP (.pgpassにアカウント登録済み)

root@ubuntu:~/tool$ cat pg_loop_write.sh
#! /bin/sh

echo 'Aurora testdbにデータを継続的にINSERTします'


for r in `seq 1 10000`
        do
        #insert into schema_name.table_name(id) values(r);
        #psql -h localhost -p 54320 -U postgres testdb -c "select date,amount,amount_max,left_seat from fees limit 1;"
        psql -h localhost -p 54320 -U postgres testdb -c "insert into aurora_test(id,memo) values(nextval('aurora_test_id'),'Aurora Failover Test 2020年12月');" 
        echo "Insert Loop処理中です $r 回目";
        #sleep 0.5
done

echo 'END LOOP'
root@ubuntu:~/tool$


########## テストSELECT LOOP  (.pgpassにアカウント登録済み)


root@ubuntu:~/tool# cat pg_loop_read.sh
#! /bin/sh

echo 'Aurora testdbからデータを継続的にSELECTします'


for r in `seq 1 10000`
        do
        #insert into schema_name.table_name(id) values(r);
        psql -h localhost -p 54321 -U postgres testdb -c "select count(*),now() from aurora_test;"
        #psql -h localhost -p 54320 -U postgres testdb -c "insert into aurora_test(id,memo) values(nextval('aurora_test_id'),'Aurora Failover Test 2020年12月');"

        echo "Select Loop処理中です $r 回目";
        #sleep 0.5
done

echo 'END LOOP'
root@ubuntu:~/tool#





########## Windows関数でIDをソートして処理時間のLagを確認する。


testdb=> select id, created, lag(created) over (order by id) from aurora_test limit 10;
 id |          created           |            lag
----+----------------------------+----------------------------
  1 | 2020-12-22 12:41:26.420351 |
  2 | 2020-12-22 12:41:27.848862 | 2020-12-22 12:41:26.420351
  3 | 2020-12-22 12:41:29.25691  | 2020-12-22 12:41:27.848862
  4 | 2020-12-22 12:41:30.701786 | 2020-12-22 12:41:29.25691
  5 | 2020-12-22 12:41:32.211611 | 2020-12-22 12:41:30.701786
  6 | 2020-12-22 12:41:33.695846 | 2020-12-22 12:41:32.211611
  7 | 2020-12-22 12:41:35.221218 | 2020-12-22 12:41:33.695846
  8 | 2020-12-22 12:41:36.750707 | 2020-12-22 12:41:35.221218
  9 | 2020-12-22 12:41:38.193535 | 2020-12-22 12:41:36.750707
 10 | 2020-12-22 12:41:39.765688 | 2020-12-22 12:41:38.193535
(10 rows)


########## Windows関数でIDをソートして処理時間のLag秒数を確認する。

testdb=>  select a.id,a.created - a.lag as diff from (select id, created, lag(created) over (order by id) from aurora_test) a  limit 10;
 id |      diff
----+-----------------
  1 |
  2 | 00:00:01.428511
  3 | 00:00:01.408048
  4 | 00:00:01.444876
  5 | 00:00:01.509825
  6 | 00:00:01.484235
  7 | 00:00:01.525372
  8 | 00:00:01.529489
  9 | 00:00:01.442828
 10 | 00:00:01.572153
(10 rows)


########## 抜けているSequenceを確認する。

testdb=> select a.id - a.lag as diff from (select id, created, lag(id) over (order by id) from aurora_test) a order by diff desc limit 10;
 diff
------

   31
   29
   28
   19
   17
   13
    1
    1
    1
(10 rows)

testdb=>




########## 抜けているSequenceと処理時間から間隔を確認する。


testdb=>  select a.id,a.created - a.lag as diff from (select id, created, lag(created) over (order by id) from aurora_test) a where a.id >= 1160 limit 3;
  id  |      diff
------+-----------------
 1160 | 00:00:01.911308
 1161 | 00:00:01.997045
 1189 | 00:00:05.636869
(3 rows)

testdb=> select * from aurora_test where id in (1160,1161,1189);
  id  |         memo                    |          created
------+---------------------------------+----------------------------
 1160 | Aurora Failover Test 2020年12月 | 2020-12-22 13:16:59.232346
 1161 | Aurora Failover Test 2020年12月 | 2020-12-22 13:17:01.229391
 1189 | Aurora Failover Test 2020年12月 | 2020-12-22 13:17:06.86626
(3 rows)

testdb=>

