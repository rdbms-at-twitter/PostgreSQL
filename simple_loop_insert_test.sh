#! /bin/sh

###########################################################################
# 1) 以下、パスワードを入れて無くても良い様に自分のホームに.pgpassを作成
# shinya@ubuntu:~$ cat ~/.pgpass
# host:5432:testdb:user:password
#
# 2) テスト用のテーブル作成
#    testdb=> CREATE SEQUENCE aurora_test_id START 1;
#    CREATE SEQUENCE
#    testdb=> create table aurora_test (id integer DEFAULT nextval('aurora_test_id'),memo varchar (100));
#    CREATE TABLE
#
#
###########################################################################

echo 'Aurora DBにデータを継続的にINSERTします'


for r in `seq 1 10000`

           do
		   #insert into schema_name.table_name(id) values(r);
		   #psql -h localhost -p 5432 -U user testdb -c "select count(*) from aurora_test;"
		   psql -h localhost -p 5432 -U user testdb -c "insert into aurora_test(id,memo) values(nextval('aurora_test_id'),'Aurora Failover Test 2020年12月');"
		   echo "Insert Loop処理中です $r 回目";
	   done

echo 'END LOOP'
