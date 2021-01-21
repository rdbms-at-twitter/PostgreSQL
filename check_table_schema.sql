select table_schema, table_name from information_schema.tables where not table_schema='pg_catalog' and not table_schema='information_schema' and table_name = '<tablename>';
