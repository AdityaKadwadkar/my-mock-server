-- Fix student_id data type in student_course table

-- Drop foreign key constraint if it exists
ALTER TABLE student_course DROP CONSTRAINT IF EXISTS student_course_student_id_fkey;

-- Alter column type to VARCHAR
ALTER TABLE student_course ALTER COLUMN student_id TYPE VARCHAR(50) USING student_id::varchar;

-- Add foreign key constraint referencing students(student_id)
ALTER TABLE student_course ADD CONSTRAINT student_course_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE;
