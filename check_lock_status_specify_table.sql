SELECT
pg_stat_activity.pid,
pg_locks.granted,
pg_class.relname AS "Table"
, CASE WHEN pg_locks.granted = 't' THEN 'Lock' ELSE 'Waiting for Lock' END AS "Lock Status"
, pg_locks.mode AS "Lock Level"
, pg_stat_activity.state AS "Transacton Status"
, left(pg_stat_activity.query,20) AS "Last Query"
, pg_stat_activity.query_start AS "Last Query Started Time"
, CASE WHEN pg_stat_activity.state = 'active' THEN current_timestamp - pg_stat_activity.query_start END AS "Duration"
FROM
pg_locks INNER JOIN pg_stat_activity ON pg_locks.pid = pg_stat_activity.pid
INNER JOIN pg_class ON pg_locks.relation = pg_class.oid
WHERE pg_locks.locktype = 'relation';
