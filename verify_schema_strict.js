const { Pool } = require('pg');
const pool = new Pool({
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'mock_contineo',
});

// Since the app might not have run initialization yet if we just updated the file,
// we should run the migrations manually or ensure the app runs them.
// The `src/config/database.js` has `initializeDatabase` but we need to trigger it.
// I'll read the sql file and execute it first to be sure the db is in the correct state for validation.

const fs = require('fs');
const path = require('path');

async function runValidation() {
    try {
        console.log('--- STRICT SCHEMA VALIDATION ---');

        // 1. Force Initialize Database with new Schema
        console.log('Initializing database with new schema...');
        const migrationPath = path.join(__dirname, 'src/migrations/init.sql');
        const sql = fs.readFileSync(migrationPath, 'utf8');
        await pool.query(sql);
        console.log('Database initialized.');

        // 2. Run Mandatory Query
        console.log('Running mandatory query...');
        const res = await pool.query(`
            SELECT column_name
            FROM information_schema.columns
            WHERE table_name = 'student';
        `);

        const columns = res.rows.map(r => r.column_name);
        console.log('Found columns:', columns);

        const required = ['division', 'section', 'course_enrolled'];
        const missing = required.filter(c => !columns.includes(c));

        if (missing.length > 0) {
            console.error('❌ VALIDATION FAILED! Missing columns:', missing);
            process.exit(1);
        } else {
            console.log('✅ VALIDATION PASSED: division, section, course_enrolled are present.');
        }

        // 3. Verify Program column is ABSENT
        if (columns.includes('program')) {
            console.error('❌ VALIDATION FAILED! Forbidden column "program" is present.');
            process.exit(1);
        } else {
            console.log('✅ VALIDATION PASSED: Forbidden column "program" is absent.');
        }

        process.exit(0);

    } catch (err) {
        console.error('Error during validation:', err);
        process.exit(1);
    }
}

runValidation();
