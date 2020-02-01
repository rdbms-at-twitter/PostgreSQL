SELECT s.pid,
    s.usesysid,
    u.rolname AS usename,
    s.application_name,
    s.client_addr,
    s.client_hostname,
    s.backend_start,
    w.state,
    w.sent_location,
    w.write_location,
    w.flush_location,
    w.replay_location
   FROM pg_stat_get_activity(NULL::integer) s(datid, pid, usesysid,
	application_name, state, query, waiting, xact_start, query_start,
	backend_start, state_change, client_addr, client_hostname, client_port),
    pg_authid u,
    pg_stat_get_wal_senders() w(pid, state, sent_location, write_location,
	flush_location, replay_location, sync_priority, sync_state)
  WHERE s.usesysid = u.oid AND s.pid = w.pid;
