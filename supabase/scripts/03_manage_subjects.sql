-- Admin Script: Manage Subjects
-- Usage: Run this script in Supabase SQL Editor to add, update, or delete subjects

-- Add new subjects
INSERT INTO subjects (name, code) VALUES
    ('Psychology', 'psychology'),
    ('Political Science', 'political_science'),
    ('Statistics', 'statistics'),
    ('Engineering Drawing', 'engineering_drawing'),
    ('Home Economics', 'home_economics');

-- Update an existing subject
UPDATE subjects SET name = 'Computer Science' WHERE code = 'computer_studies';

-- Delete a subject (be cautious as this may affect course requirements)
-- DELETE FROM subjects WHERE code = 'home_economics';

-- List all subjects
SELECT name, code FROM subjects ORDER BY name;

-- Check if a subject is used in any course requirements
SELECT s.name as subject_name, s.code as subject_code, COUNT(cr.id) as requirement_count
FROM subjects s
LEFT JOIN course_requirements cr ON s.id = cr.subject_id
GROUP BY s.id, s.name, s.code
ORDER BY requirement_count DESC, s.name;