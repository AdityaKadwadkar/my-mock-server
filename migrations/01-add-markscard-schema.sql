-- Migration: Add Markscard Support Fields
-- Grade System: S(10), A(9), B(8), C(7), D(6), F(0)

-- Add year & semester to students
ALTER TABLE students ADD COLUMN IF NOT EXISTS year INTEGER;
ALTER TABLE students ADD COLUMN IF NOT EXISTS semester INTEGER;

-- Add year, semester, course_code to courses
ALTER TABLE courses ADD COLUMN IF NOT EXISTS year INTEGER;
ALTER TABLE courses ADD COLUMN IF NOT EXISTS semester INTEGER;
ALTER TABLE courses ADD COLUMN IF NOT EXISTS course_code VARCHAR(50) UNIQUE;

-- Add gpa to marks
ALTER TABLE marks ADD COLUMN IF NOT EXISTS gpa DECIMAL(3,2) DEFAULT 0.00;

-- Populate GPA values from grades (S, A, B, C, D, F)
UPDATE marks SET gpa = CASE 
  WHEN grade = 'S' THEN 10.00
  WHEN grade = 'A' THEN 9.00
  WHEN grade = 'B' THEN 8.00
  WHEN grade = 'C' THEN 7.00
  WHEN grade = 'D' THEN 6.00
  WHEN grade = 'F' THEN 0.00
  ELSE 0.00
END WHERE gpa IS NULL OR gpa = 0.00;

-- Create markscard storage tables
CREATE TABLE IF NOT EXISTS markscard (
  id SERIAL PRIMARY KEY,
  markscard_id VARCHAR(100) UNIQUE NOT NULL,
  student_id VARCHAR(50) NOT NULL,
  department VARCHAR(100) NOT NULL,
  semester INTEGER NOT NULL,
  year INTEGER NOT NULL,
  total_credits INTEGER,
  sgpa DECIMAL(5,2),
  generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  credential_data JSONB,
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_markscard_student ON markscard(student_id);
CREATE INDEX IF NOT EXISTS idx_markscard_semester ON markscard(semester, year);

CREATE TABLE IF NOT EXISTS credential_history (
  id SERIAL PRIMARY KEY,
  markscard_id VARCHAR(100),
  student_id VARCHAR(50),
  action VARCHAR(50),
  ip_address VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(student_id)
);