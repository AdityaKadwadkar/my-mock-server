const MarksCardModel = require('../models/Markscard');

class MarksCardController {
  static async getMarksCard(req, res) {
    try {
      const { studentId, semester, year } = req.query;
      if (!studentId || !semester || !year) {
        return res.status(400).json({ success: false, message: 'Missing required parameters' });
      }
      const data = await MarksCardModel.getStudentMarksCard(studentId, parseInt(semester), parseInt(year));
      await MarksCardModel.saveMarksCard(studentId, parseInt(semester), parseInt(year), data);
      res.status(200).json(data);
    } catch (err) {
      console.error('Error in getMarksCard:', err);
      res.status(500).json({ success: false, message: err.message });
    }
  }

  static async getMarksCardById(req, res) {
    try {
      const { marksCardId } = req.params;
      const markscard = await MarksCardModel.getMarksCardById(marksCardId);
      if (!markscard) return res.status(404).json({ success: false, message: 'Not found' });
      res.status(200).json({ success: true, data: JSON.parse(markscard.credential_data) });
    } catch (err) {
      console.error('Error:', err);
      res.status(500).json({ success: false, message: err.message });
    }
  }

  static async getStudentMarkscards(req, res) {
    try {
      const { studentId } = req.params;
      const markscards = await MarksCardModel.getStudentMarkscards(studentId);
      res.status(200).json({ success: true, data: markscards });
    } catch (err) {
      res.status(500).json({ success: false, message: err.message });
    }
  }

  static async generateBatchMarkscards(req, res) {
    try {
      const { department, year, semester } = req.body;
      if (!department || !year || !semester) {
        return res.status(400).json({ success: false, message: 'Missing parameters' });
      }
      const db = require('../config/database');
      const studentsQuery = `SELECT DISTINCT student_id FROM students WHERE department = $1 AND year = $2 AND semester = $3`;
      const studentsResult = await db.query(studentsQuery, [department, year, semester]);
      const students = studentsResult.rows;

      const results = [];
      for (const student of students) {
        try {
          const data = await MarksCardModel.getStudentMarksCard(student.student_id, semester, year);
          const saved = await MarksCardModel.saveMarksCard(student.student_id, semester, year, data);
          results.push({ student_id: student.student_id, status: 'success', markscard_id: saved.markscard_id });
        } catch (err) {
          results.push({ student_id: student.student_id, status: 'error', message: err.message });
        }
      }
      res.status(200).json({ success: true, generated: results.filter(r => r.status === 'success').length, failed: results.filter(r => r.status === 'error').length, results });
    } catch (err) {
      res.status(500).json({ success: false, message: err.message });
    }
  }
}

module.exports = MarksCardController;