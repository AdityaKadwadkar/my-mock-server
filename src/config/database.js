require('dotenv').config();
const pg = require('pg');
const fs = require('fs');
const path = require('path');

const { Pool } = pg;

const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'admin123',
  host: process.env.DB_HOST || '127.0.0.1',  // 🔥 FIX
  port: process.env.DB_PORT || 5433,
  database: process.env.DB_NAME || 'mock_contineo',
  max: 20
});

async function initializeDatabase() {
  try {
    const migrationPath = path.join(__dirname, '../migrations/init.sql');
    const sql = fs.readFileSync(migrationPath, 'utf8');
    await pool.query(sql);
  } catch (error) {
    console.error('Database init error:', error);
    throw error;
  }
}

async function query(text, params) {
  return await pool.query(text, params);
}

module.exports = { query, pool, initializeDatabase };
