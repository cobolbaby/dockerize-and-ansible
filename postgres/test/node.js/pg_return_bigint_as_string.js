const { Pool, types } = require('pg');

types.setTypeParser(types.builtins.INT8, (val) => parseInt(val));

// PostgreSQL数据库连接配置
const pool = new Pool({
    user: 'your_username',
    host: 'your_host',
    database: 'your_database',
    password: 'your_password',
    port: 5432,
});

// 测试用例
async function testQuery() {
    const client = await pool.connect();

    try {
        // 'plt_usage' 为bigint字段名
        const queryText = 'select plt_usage from plt_spare_sparesnusage limit 1';
        const result = await client.query(queryText);

        // 输出查询结果的数据类型和值
        if (result.rows.length > 0) {
            const bigintValue = result.rows[0].plt_usage;
            console.log(`Type of bigint column: ${typeof bigintValue}`);
            console.log(`Value of bigint column: ${bigintValue}`);
        } else {
            console.log('No rows returned from the query.');
        }
    } catch (error) {
        console.error('Error executing query:', error);
    } finally {
        client.release();
        // 关闭数据库连接池
        pool.end();
    }
}

// 执行测试用例
testQuery();
