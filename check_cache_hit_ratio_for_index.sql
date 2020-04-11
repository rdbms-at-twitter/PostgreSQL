select (idx_blks_hit*100.0)/(idx_blks_hit+idx_blks_read) from pg_statio_user_indexes where indexrelname = 'idx_memo_id';
