const express = require('express');
const cors = require('cors');
const path = require('path');
const marksCardRoutes = require('./routes/markscard');
const app = express();
const studentRoutes = require('./routes/studentRoutes');
const courseRoutes = require('./routes/courseRoutes');
const marksRoutes = require('./routes/marksRoutes');

app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.static(path.join(__dirname, 'public')));
app.use('/api', marksCardRoutes);
app.use('/api', studentRoutes);
app.use('/api', courseRoutes);
app.use('/api', marksRoutes);
app.use('/api', require('./routes/facultyRoutes'));

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: err.message });
});

module.exports = app;
