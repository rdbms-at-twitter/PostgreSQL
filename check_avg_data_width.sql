#行長と行数をpg_statsを手動で確認。プランナーがコストを推定する場合は、pg_statisticを参照。
select tablename,attname,avg_width from pg_stats where tablename = '<テーブル名>;

