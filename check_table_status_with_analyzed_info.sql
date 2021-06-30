SELECT
pp.relname as "Table",
pc.relkind AS objecttype,
pc.reltuples AS "#entries", 
pg_size_pretty(pg_total_relation_size(pp.relid)) As "Total Size",
pg_size_pretty(pc.relpages::bigint*8*1024) AS "Table size",
pg_size_pretty(pg_total_relation_size(pp.relid) - pg_relation_size(pp.relid)) as "External Size(idx)",
psut.relname,psut.vacuum_count,psut.autovacuum_count,psut.analyze_count,psut.autoanalyze_count
FROM pg_catalog.pg_statio_user_tables pp 
inner join pg_class pc on pp.relname = pc.relname
inner join pg_stat_user_tables psut on pp.relname = psut.relname
ORDER BY pg_total_relation_size(pp.relid) DESC;

