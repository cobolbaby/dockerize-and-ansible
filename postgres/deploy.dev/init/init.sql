-- 192.168.2.120 5493

CREATE USER IPTMesUser WITH LOGIN PASSWORD '???';
-- DROP DATABASE dwf;
CREATE DATABASE dwf OWNER IPTMesUser;

\c dwf
-- 回收默认权限
ALTER SCHEMA public OWNER TO IPTMesUser;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE CONNECT ON DATABASE template1 FROM PUBLIC;
REVOKE CONNECT ON DATABASE dwf FROM PUBLIC;
CREATE EXTENSION postgres_fdw;
GRANT USAGE ON foreign data wrapper postgres_fdw to IPTMesUser;
\q

-- pg_dump -h 192.168.16.91 -p 5493 -U postgres -Fc -O -x postgres | pg_restore --no-owner -U iptmesuser -d dwf
-- CREATE USER MAPPING FOR IPTMesUser SERVER dwf_postgres_fdw_server_246 OPTIONS (
--     password '123456',
--     "user" 'postgres'
-- );
