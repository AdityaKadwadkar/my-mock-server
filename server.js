require('dotenv').config();
const app = require('./src/app');
const { initializeDatabase } = require('./src/config/database');

const PORT = process.env.PORT || 3001;

(async () => {
  try {
    console.log(`[${new Date().toISOString()}] Initializing Mock-Contineo...`);
    await initializeDatabase();
    console.log('[Database] Connected');

    app.listen(PORT, () => {
      console.log(`[Server] Running on http://localhost:${PORT}`);
      console.log(`[Admin UI] http://localhost:${PORT}`);
      console.log(`[API] http://localhost:${PORT}/api`);
    });
  } catch (error) {
    console.error('[Error]', error);
    process.exit(1);
  }
})();
