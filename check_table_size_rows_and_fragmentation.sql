SELECT
pp.relname as "Table",
pc.relkind AS objecttype,
pc.reltuples AS "#entries", 
pg_size_pretty(pg_total_relation_size(pp.relid)) As "Total Size",
pg_size_pretty(pc.relpages::bigint*8*1024) AS "Table size",
pg_size_pretty(pg_total_relation_size(pp.relid) - pg_relation_size(pp.relid)) as "External Size(idx)",
pat.n_live_tup,pat.n_dead_tup,round(pat.n_dead_tup*100/(pat.n_live_tup+pat.n_dead_tup) ,2) AS fragment_ratio
FROM pg_catalog.pg_statio_user_tables pp inner join pg_class pc on pp.relname = pc.relname
inner join pg_stat_all_tables pat on pat.relname = pc.relname
where pat.n_dead_tup <> 0 
ORDER BY pg_total_relation_size(pp.relid) DESC;
