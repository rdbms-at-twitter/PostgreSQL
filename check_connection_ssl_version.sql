SELECT datname,usename, ssl, client_addr,version,count(*)  FROM pg_stat_ssl
JOIN pg_stat_activity ON pg_stat_ssl.pid = pg_stat_activity.pid
group by datname,usename, ssl, client_addr,version;
