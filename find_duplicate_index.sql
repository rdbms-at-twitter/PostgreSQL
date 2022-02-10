SELECT   indrelid::regclass table_name,
         att.attname column_name,
         amname index_method
FROM     pg_index i,
         pg_class c,
         pg_opclass o,
         pg_am a,
         pg_attribute att
WHERE    o.oid = ALL (indclass) 
AND      att.attnum = ANY(i.indkey)
AND      a.oid = o.opcmethod
AND      att.attrelid = c.oid
AND      c.oid = i.indrelid
GROUP BY table_name, 
         att.attname,
         indclass,
         amname, indkey
HAVING count(*) > 1;
