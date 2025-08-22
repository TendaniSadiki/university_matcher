-- Admin Script: Manage Universities and Faculties
-- Usage: Run this script in Supabase SQL Editor to add, update, or delete universities and faculties

-- Add a new university
INSERT INTO universities (name, code, description, website_url) VALUES
    ('University of Example', 'example', 'A new university for demonstration purposes.', 'https://www.example.edu');

-- Add faculties for the new university
INSERT INTO faculties (university_id, name, code, description) VALUES
    ((SELECT id FROM universities WHERE code = 'example'), 'Faculty of Engineering', 'eng', 'Offers engineering programs.'),
    ((SELECT id FROM universities WHERE code = 'example'), 'Faculty of Arts', 'arts', 'Focuses on liberal arts and humanities.');

-- Update an existing university
UPDATE universities SET description = 'Updated description for Limkokwing University.' WHERE code = 'limkokwing';

-- Delete a university (be cautious as this will cascade delete related faculties and courses)
-- DELETE FROM universities WHERE code = 'example';

-- List all universities and their faculties
SELECT u.name as university_name, u.code as university_code, f.name as faculty_name, f.code as faculty_code
FROM universities u
LEFT JOIN faculties f ON u.id = f.university_id
ORDER BY u.name, f.name;