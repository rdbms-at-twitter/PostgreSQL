SELECT c.relname,u.usename 
  FROM pg_class c, pg_user u
 WHERE c.relowner = u.usesysid and c.relkind = 'S'
   AND relnamespace IN (
                        SELECT oid
                          FROM pg_namespace
                         WHERE nspname NOT LIKE 'pg_%'
                           AND nspname != 'information_schema'
                        )
and c.relname like '<tablename>%';
