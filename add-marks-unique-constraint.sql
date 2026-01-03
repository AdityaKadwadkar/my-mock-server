-- Add unique constraint to marks table for ON CONFLICT support
ALTER TABLE marks ADD CONSTRAINT marks_student_course_unique UNIQUE (student_id, course_id);
