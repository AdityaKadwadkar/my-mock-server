-- Insert test marks data
INSERT INTO marks (student_id, course_id, internal_marks, external_marks, total_marks, grade, gpa, grading_date) VALUES
('STU001', 1, 35, 62, 97, 'A', 9.00, '2023-04-30'),
('STU001', 2, 32, 58, 90, 'A', 9.00, '2023-09-30'),
('STU001', 3, 38, 65, 103, 'S', 10.00, '2024-04-30'),
('STU002', 1, 30, 55, 85, 'B', 8.00, '2023-04-30'),
('STU002', 2, 28, 52, 80, 'B', 8.00, '2023-09-30');

SELECT COUNT(*) as total_marks FROM marks;
SELECT student_id, grade, gpa FROM marks;