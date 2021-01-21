SELECT
 p.oid AS prooid,
 p.proname,
 p.proretset,
 pg_catalog.format_type(p.prorettype, NULL) AS proresult,
 pg_catalog.oidvectortypes(p.proargtypes) AS proarguments,
 pl.lanname AS prolanguage,
 pg_catalog.obj_description(p.oid, 'pg_proc') AS procomment,
 p.proname || ' (' || pg_catalog.oidvectortypes(p.proargtypes) || ')' AS proproto,
 CASE WHEN p.proretset THEN 'setof ' ELSE '' END || pg_catalog.format_type(p.prorettype, NULL) AS proreturns,
 u.usename AS proowner
FROM pg_catalog.pg_proc p
 INNER JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
 INNER JOIN pg_catalog.pg_language pl ON pl.oid = p.prolang
 LEFT JOIN pg_catalog.pg_user u ON u.usesysid = p.proowner
WHERE n.nspname = 'rdsadmin'
ORDER BY p.proname, proresult;
