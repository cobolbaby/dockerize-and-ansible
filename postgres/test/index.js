const { Pool, Client } = require('pg')

const connCfg = {
    user: 'insightuser',
    host: '10.191.7.119',
    database: 'insight',
    password: 'insightuser',
    port: 5493,
}

// Ref: https://node-postgres.com/features/connecting
;(async () => {
    // pools will use environment variables
    // for connection information
    const pool = new Pool(connCfg)
    pool.on('error', (err, client) => {
        console.error('Unexpected error on idle client', err)
        process.exit(-1)
    })

    try {
        const client = await pool.connect()
        const res = await client.query('SELECT NOW()')
        console.log(res.rows[0])

        // Make sure to release the client before any error handling,
        // just in case the error handling itself throws an error.
        client.release()
    } catch(error) {
        console.error('Error running query', error)
    }

    // clients will also use environment variables
    // for connection information
    const client2 = new Client(connCfg)
    
    try {
        await client2.connect()
        const res = await client2.query('SELECT NOW()')
        console.log(res.rows[0])
    } finally {
        await client2.end()
    }
    
})()


