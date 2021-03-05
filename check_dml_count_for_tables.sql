select relname, n_tup_ins as insert_count, n_tup_upd as update_count, n_tup_del as delete_count from pg_stat_user_tables order by relname;
