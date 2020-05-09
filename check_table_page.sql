SELECT relname,relpages page数, reltuples 行数, reltuples/relpages as page毎のデータ数 from pg_class where  relname = 'テーブル名';
