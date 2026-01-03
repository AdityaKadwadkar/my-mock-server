-- Migration: Fix student_id data type in marks table
ALTER TABLE marks ADD COLUMN IF NOT EXISTS student_code VARCHAR(50);

UPDATE marks m
SET student_code = s.student_id
FROM students s
WHERE m.student_id = s.id;

ALTER TABLE marks DROP COLUMN student_id;

ALTER TABLE marks RENAME COLUMN student_code TO student_id;

SELECT COUNT(*) as mark_count FROM marks;
SELECT student_id, grade, gpa FROM marks LIMIT 5;