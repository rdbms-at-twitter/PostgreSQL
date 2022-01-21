SELECT
pg_cancel_backend(pid) FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '10 minutes';
