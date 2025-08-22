-- Admin Script: Manage Courses and Requirements
-- Usage: Run this script in Supabase SQL Editor to add, update, or delete courses and their requirements

-- Add a new course to an existing faculty
INSERT INTO courses (faculty_id, name, code, duration, description, total_aps_required) VALUES
    ((SELECT id FROM faculties WHERE code = 'sci-tech'), 'Bachelor of Science in Environmental Science', 'bsc-env', '4 years', 'Focuses on environmental conservation and sustainability.', 25);

-- Add requirements for the new course
INSERT INTO course_requirements (course_id, subject_id, min_score, explanation) VALUES
    ((SELECT id FROM courses WHERE code = 'bsc-env'), (SELECT id FROM subjects WHERE code = 'science'), 6, 'Strong science background required for environmental studies.'),
    ((SELECT id FROM courses WHERE code = 'bsc-env'), (SELECT id FROM subjects WHERE code = 'math'), 5, 'Mathematical skills for data analysis in environmental science.'),
    ((SELECT id FROM courses WHERE code = 'bsc-env'), (SELECT id FROM subjects WHERE code = 'geography'), 5, 'Geography knowledge beneficial for environmental mapping.');

-- Update an existing course's requirements
UPDATE course_requirements SET min_score = 6 WHERE course_id = (SELECT id FROM courses WHERE code = 'bsc-cs') AND subject_id = (SELECT id FROM subjects WHERE code = 'math');

-- Delete a course (cascades to course_requirements)
-- DELETE FROM courses WHERE code = 'bsc-env';

-- List all courses with their faculties and universities
SELECT u.name as university_name, f.name as faculty_name, c.name as course_name, c.code as course_code, c.total_aps_required
FROM courses c
JOIN faculties f ON c.faculty_id = f.id
JOIN universities u ON f.university_id = u.id
ORDER BY u.name, f.name, c.name;

-- List course requirements for a specific course
SELECT c.name as course_name, s.name as subject_name, cr.min_score, cr.explanation
FROM course_requirements cr
JOIN courses c ON cr.course_id = c.id
JOIN subjects s ON cr.subject_id = s.id
WHERE c.code = 'bsc-cs'
ORDER BY s.name;