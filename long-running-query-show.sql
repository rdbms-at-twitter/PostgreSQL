SELECT * FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '3 minutes';
