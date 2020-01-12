select * from pg_stat_replication;
select pg_wal_lsn_diff(sent_lsn,write_lsn) write_diff_byte,pg_wal_lsn_diff(sent_lsn,flush_lsn) flush_diff_byte,pg_wal_lsn_diff(sent_lsn,replay_lsn) replay_diff_byte from pg_stat_replication;

