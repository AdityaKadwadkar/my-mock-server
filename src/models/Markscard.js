const db = require('../config/database');

class MarksCardModel {
  static generateMarksCardId(studentId, semester, year) {
    const timestamp = Date.now().toString(36).toUpperCase();
    return `MC-${studentId}-${year}${semester}-${timestamp}`;
  }

  static async getStudentMarksCard(studentId, semester, year) {
    try {
      const studentQuery = `
        SELECT id, student_id, first_name, last_name, department, year, semester, email
        FROM students
        WHERE student_id = $1
      `;
      const studentResult = await db.query(studentQuery, [studentId]);
      if (!studentResult.rows.length) throw new Error('Student not found');
      const student = studentResult.rows[0];

      const coursesQuery = `
        SELECT c.id, c.course_code, c.course_name, c.credits, c.department, c.year, c.semester
        FROM courses c
        WHERE c.department = $1 AND c.year = $2 AND c.semester = $3
        ORDER BY c.course_code
      `;
      const coursesResult = await db.query(coursesQuery, [student.department, year, semester]);

      const marksQuery = `
        SELECT m.id, m.student_id, m.course_id, m.internal_marks, m.external_marks, 
               m.total_marks, m.grade, m.gpa, c.course_code, c.course_name, c.credits
        FROM marks m
        JOIN courses c ON m.course_id = c.id
        WHERE m.student_id = (SELECT id FROM students WHERE student_id = $1)
        AND c.year = $2 AND c.semester = $3
        ORDER BY c.course_code
      `;
      const marksResult = await db.query(marksQuery, [studentId, year, semester]);
      const marks = marksResult.rows;

      let totalCredits = 0;
      let weightedSum = 0;
      marks.forEach(mark => {
        const credits = mark.credits || 0;
        const gpa = mark.gpa || 0;
        totalCredits += credits;
        weightedSum += gpa * credits;
      });
      const sgpa = totalCredits > 0 ? (weightedSum / totalCredits).toFixed(2) : 0;

      return {
        success: true,
        markscard_id: this.generateMarksCardId(studentId, semester, year),
        student: {
          student_id: student.student_id,
          name: `${student.first_name} ${student.last_name}`,
          department: student.department,
          semester,
          year,
          email: student.email
        },
        courses: marks.map(m => ({
          course_code: m.course_code,
          course_name: m.course_name,
          credits: m.credits,
          internal_marks: m.internal_marks || 0,
          external_marks: m.external_marks || 0,
          total_marks: m.total_marks || 0,
          grade: m.grade || 'N/A',
          gpa: m.gpa || 0
        })),
        totalCredits,
        sgpa: parseFloat(sgpa),
        generated_at: new Date().toISOString().split('T')[0]
      };
    } catch (err) {
      console.error('Error fetching markscard:', err);
      throw err;
    }
  }

  static async saveMarksCard(studentId, semester, year, data) {
    try {
      const marksCardId = this.generateMarksCardId(studentId, semester, year);
      const query = `
        INSERT INTO markscard (markscard_id, student_id, department, semester, year, total_credits, sgpa, credential_data)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        ON CONFLICT (markscard_id) DO UPDATE SET credential_data = $8, generated_at = CURRENT_TIMESTAMP
        RETURNING *
      `;
      const result = await db.query(query, [marksCardId, studentId, data.student.department, semester, year, data.totalCredits, data.sgpa, JSON.stringify(data)]);
      return result.rows[0];
    } catch (err) {
      console.error('Error saving markscard:', err);
      throw err;
    }
  }

  static async getMarksCardById(marksCardId) {
    try {
      const query = 'SELECT * FROM markscard WHERE markscard_id = $1';
      const result = await db.query(query, [marksCardId]);
      return result.rows[0];
    } catch (err) {
      console.error('Error fetching markscard by ID:', err);
      throw err;
    }
  }

  static async getStudentMarkscards(studentId) {
    try {
      const query = `SELECT markscard_id, student_id, department, semester, year, sgpa, generated_at FROM markscard WHERE student_id = $1 ORDER BY year DESC, semester DESC`;
      const result = await db.query(query, [studentId]);
      return result.rows;
    } catch (err) {
      console.error('Error fetching student markscards:', err);
      throw err;
    }
  }
}

module.exports = MarksCardModel;