// src/routes/courseRoutes.js
const express = require('express');
const router = express.Router();
const multer = require('multer');
const pool = require('../config/database').pool;

const upload = multer({ storage: multer.memoryStorage() });

function parseCSV(buffer, requiredHeaders) {
  const text = buffer.toString('utf8').trim();
  const [headerLine, ...lines] = text.split(/\r?\n/);
  const headers = headerLine.split(',').map(h => h.trim());

  const missing = requiredHeaders.filter(h => !headers.includes(h));
  if (missing.length > 0) {
    throw new Error(`Missing required columns: ${missing.join(', ')}`);
  }

  return lines
    .filter(l => l.trim())
    .map(line => {
      const values = line.split(',');
      const row = {};
      headers.forEach((h, i) => (row[h] = (values[i] || '').trim()));
      return row;
    });
}

const COURSE_COLS = [
  'course_id', 'course_code', 'course_name', 'department', 'credits', 'semester'
];

router.post('/upload/courses', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ success: false, message: 'No file uploaded' });

    let rows;
    try {
      rows = parseCSV(req.file.buffer, COURSE_COLS);
    } catch (e) {
      return res.status(400).json({ success: false, message: e.message });
    }

    for (const r of rows) {
      await pool.query(
        `INSERT INTO COURSE
         (course_id, course_code, course_name, department, credits, semester)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [
          r.course_id,
          r.course_code,
          r.course_name,
          r.department,
          parseInt(r.credits) || 0,
          parseInt(r.semester) || 1
        ]
      );
    }

    res.status(200).json({ success: true, inserted: rows.length });
  } catch (err) {
    console.error('Upload courses error:', err);
    res.status(500).json({ success: false, inserted: 0, message: err.message });
  }
});

router.get('/courses', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM COURSE ORDER BY course_code');
    res.json({ success: true, data: result.rows });
  } catch (err) {
    console.error('Get courses error:', err);
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
