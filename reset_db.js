const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

const pool = new Pool({
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'mock_contineo'
});

async function resetDB() {
    try {
        const sqlPath = path.join(__dirname, 'src/migrations/init.sql');
        const sql = fs.readFileSync(sqlPath, 'utf8');
        console.log('Resetting DB with SQL from:', sqlPath);
        await pool.query(sql);
        console.log('✅ Database reset successfully to strict schema.');
        process.exit(0);
    } catch (e) {
        console.error('❌ Reset failed:', e);
        process.exit(1);
    }
}

resetDB();
