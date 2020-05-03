select * from pg_stats where schemaname = 'public' and tablename = 'tablename' and attname = 'row_name' limit 10;
