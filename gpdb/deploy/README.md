#### 数据库访问方式

- postgresql://gpadmin:@172.25.57.1:5483/postgres

#### 常用 SQL

- 修改 gpadmin 用户密码

```sql
ALTER USER gpadmin WITH PASSWORD 'bdcc+chicony';
```

- 创建数据库

```sql
CREATE USER bdcuser WITH LOGIN PASSWORD 'bdcc+chicony'; 
CREATE DATABASE chicony OWNER bdcuser;
\c chicony
-- 回收默认权限
ALTER SCHEMA public OWNER TO bdcuser;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE CONNECT ON DATABASE template1 FROM PUBLIC;
REVOKE CONNECT ON DATABASE chicony FROM PUBLIC;
```
