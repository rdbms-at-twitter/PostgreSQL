SELECT tablename,attname,correlation, inherited, n_distinct,array_to_string(most_common_vals, E'\n') as most_common_vals FROM pg_stats WHERE tablename = 'relname';
