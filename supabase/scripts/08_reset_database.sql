-- Admin Script: Reset Database to Initial State
-- Usage: Run this script in Supabase SQL Editor to reset the database to its initial seed state
-- WARNING: This will delete all existing data and recreate the schema with default data

-- Disable foreign key checks temporarily (if supported)
-- Note: PostgreSQL doesn't support disabling foreign keys, so we need to truncate in correct order

-- Truncate all tables in reverse order of dependencies
TRUNCATE TABLE events CASCADE;
TRUNCATE TABLE sessions CASCADE;
TRUNCATE TABLE learner_scores CASCADE;
TRUNCATE TABLE learners CASCADE;
TRUNCATE TABLE course_requirements CASCADE;
TRUNCATE TABLE courses CASCADE;
TRUNCATE TABLE faculties CASCADE;
TRUNCATE TABLE universities CASCADE;
TRUNCATE TABLE subjects CASCADE;
TRUNCATE TABLE grade_mappings CASCADE;

-- Insert default grade mappings for Lesotho LGCSE system
INSERT INTO grade_mappings (grade, points, description) VALUES
    ('A*', 9, 'Excellent'),
    ('A', 8, 'Very Good'),
    ('B', 7, 'Good'),
    ('C', 6, 'Credit'),
    ('D', 5, 'Pass'),
    ('E', 4, 'Weak Pass'),
    ('F', 3, 'Fail'),
    ('G', 2, 'Poor Fail');

-- Insert common LGCSE subjects
INSERT INTO subjects (name, code) VALUES
    ('Mathematics', 'math'),
    ('English', 'english'),
    ('Science', 'science'),
    ('Sesotho', 'sesotho'),
    ('History', 'history'),
    ('Geography', 'geography'),
    ('Accounting', 'accounting'),
    ('Business Studies', 'business_studies'),
    ('Economics', 'economics'),
    ('Physics', 'physics'),
    ('Chemistry', 'chemistry'),
    ('Biology', 'biology'),
    ('Agricultural Science', 'agricultural_science'),
    ('Computer Studies', 'computer_studies'),
    ('Religious Studies', 'religious_studies'),
    ('Development Studies', 'development_studies'),
    ('Art and Design', 'art_design'),
    ('Music', 'music'),
    ('Physical Education', 'physical_education'),
    ('French', 'french');

-- Insert universities
INSERT INTO universities (name, code, description, website_url) VALUES
    ('National University of Lesotho', 'nul', 'The premier institution of higher learning in Lesotho, established in 1945.', 'https://www.nul.ls'),
    ('Limkokwing University of Creative Technology', 'limkokwing', 'A global university with a focus on creativity and innovation.', 'https://www.limkokwing.net/ls');

-- Insert faculties for NUL
INSERT INTO faculties (university_id, name, code, description) VALUES
    ((SELECT id FROM universities WHERE code = 'nul'), 'Faculty of Science and Technology', 'sci-tech', 'Offers programs in natural sciences, computing, and engineering.'),
    ((SELECT id FROM universities WHERE code = 'nul'), 'Faculty of Humanities', 'humanities', 'Focuses on arts, languages, and social sciences.'),
    ((SELECT id FROM universities WHERE code = 'nul'), 'Faculty of Education', 'education', 'Dedicated to teacher training and educational sciences.');

-- Insert faculties for Limkokwing
INSERT INTO faculties (university_id, name, code, description) VALUES
    ((SELECT id FROM universities WHERE code = 'limkokwing'), 'Faculty of Creative Technology', 'creative-tech', 'Focuses on design, multimedia, and creative arts.'),
    ((SELECT id FROM universities WHERE code = 'limkokwing'), 'Faculty of Business and Management', 'business', 'Offers programs in business administration and management.'),
    ((SELECT id FROM universities WHERE code = 'limkokwing'), 'Faculty of Information Technology', 'it', 'Specializes in computing and information technology.');

-- Insert courses for NUL Faculty of Science and Technology
INSERT INTO courses (faculty_id, name, code, duration, description, total_aps_required) VALUES
    ((SELECT id FROM faculties WHERE code = 'sci-tech'), 'Bachelor of Science in Computer Science', 'bsc-cs', '4 years', 'Comprehensive program covering programming, algorithms, and software engineering.', 28),
    ((SELECT id FROM faculties WHERE code = 'sci-tech'), 'Bachelor of Science in Mathematics', 'bsc-math', '4 years', 'Focuses on pure and applied mathematics, statistics, and computational methods.', 26),
    ((SELECT id FROM faculties WHERE code = 'sci-tech'), 'Bachelor of Science in Physics', 'bsc-physics', '4 years', 'Covers classical mechanics, quantum physics, and experimental techniques.', 26),
    ((SELECT id FROM faculties WHERE code = 'sci-tech'), 'Bachelor of Science in Chemistry', 'bsc-chemistry', '4 years', 'Includes organic, inorganic, physical, and analytical chemistry.', 26),
    ((SELECT id FROM faculties WHERE code = 'sci-tech'), 'Bachelor of Science in Biology', 'bsc-biology', '4 years', 'Focuses on cell biology, genetics, ecology, and evolution.', 26);

-- Insert courses for NUL Faculty of Humanities
INSERT INTO courses (faculty_id, name, code, duration, description, total_aps_required) VALUES
    ((SELECT id FROM faculties WHERE code = 'humanities'), 'Bachelor of Arts in Economics', 'ba-economics', '4 years', 'Studies economic theory, policy, and development economics.', 24),
    ((SELECT id FROM faculties WHERE code = 'humanities'), 'Bachelor of Arts in History', 'ba-history', '4 years', 'Explores world history, African history, and historical research methods.', 22),
    ((SELECT id FROM faculties WHERE code = 'humanities'), 'Bachelor of Arts in Sociology', 'ba-sociology', '4 years', 'Examines social structures, institutions, and cultural dynamics.', 22),
    ((SELECT id FROM faculties WHERE code = 'humanities'), 'Bachelor of Arts in English', 'ba-english', '4 years', 'Focuses on literature, linguistics, and communication skills.', 24);

-- Insert courses for NUL Faculty of Education
INSERT INTO courses (faculty_id, name, code, duration, description, total_aps_required) VALUES
    ((SELECT id FROM faculties WHERE code = 'education'), 'Bachelor of Education (Primary)', 'bed-primary', '4 years', 'Prepares teachers for primary school education with pedagogical training.', 22),
    ((SELECT id FROM faculties WHERE code = 'education'), 'Bachelor of Education (Secondary)', 'bed-secondary', '4 years', 'Trains teachers for secondary school subjects and educational theory.', 24),
    ((SELECT id FROM faculties WHERE code = 'education'), 'Bachelor of Education (Science)', 'bed-science', '4 years', 'Specializes in teaching science subjects at secondary level.', 26);

-- Insert courses for Limkokwing Faculty of Creative Technology
INSERT INTO courses (faculty_id, name, code, duration, description, total_aps_required) VALUES
    ((SELECT id FROM faculties WHERE code = 'creative-tech'), 'Bachelor of Fashion Design', 'bfd', '3 years', 'Focuses on fashion design, textile technology, and fashion business.', 20),
    ((SELECT id FROM faculties WHERE code = 'creative-tech'), 'Bachelor of Graphic Design', 'bgd', '3 years', 'Covers visual communication, branding, and digital design tools.', 20),
    ((SELECT id FROM faculties WHERE code = 'creative-tech'), 'Bachelor of Multimedia Arts', 'bma', '3 years', 'Integrates animation, video production, and interactive media.', 20);

-- Insert courses for Limkokwing Faculty of Business and Management
INSERT INTO courses (faculty_id, name, code, duration, description, total_aps_required) VALUES
    ((SELECT id FROM faculties WHERE code = 'business'), 'Bachelor of Business Administration', 'bba', '3 years', 'Covers management, marketing, finance, and entrepreneurship.', 22),
    ((SELECT id FROM faculties WHERE code = 'business'), 'Bachelor of Commerce in Accounting', 'bcom-acc', '3 years', 'Focuses on accounting principles, auditing, and financial management.', 24),
    ((SELECT id FROM faculties WHERE code = 'business'), 'Bachelor of Human Resource Management', 'bhr', '3 years', 'Specializes in recruitment, training, and organizational behavior.', 22);

-- Insert courses for Limkokwing Faculty of Information Technology
INSERT INTO courses (faculty_id, name, code, duration, description, total_aps_required) VALUES
    ((SELECT id FROM faculties WHERE code = 'it'), 'Bachelor of Information Technology', 'bit', '3 years', 'Covers programming, databases, networks, and system analysis.', 24),
    ((SELECT id FROM faculties WHERE code = 'it'), 'Bachelor of Software Engineering', 'bse', '3 years', 'Focuses on software development lifecycle and engineering practices.', 26),
    ((SELECT id FROM faculties WHERE code = 'it'), 'Bachelor of Computer Systems', 'bcs', '3 years', 'Specializes in hardware, operating systems, and network infrastructure.', 24);

-- Insert course requirements for sample courses
-- BSc Computer Science requirements
INSERT INTO course_requirements (course_id, subject_id, min_score, explanation) VALUES
    ((SELECT id FROM courses WHERE code = 'bsc-cs'), (SELECT id FROM subjects WHERE code = 'math'), 6, 'Strong mathematical foundation required for algorithms and logic.'),
    ((SELECT id FROM courses WHERE code = 'bsc-cs'), (SELECT id FROM subjects WHERE code = 'english'), 5, 'Good communication skills for documentation and teamwork.'),
    ((SELECT id FROM courses WHERE code = 'bsc-cs'), (SELECT id FROM subjects WHERE code = 'physics'), 5, 'Understanding of physical principles helps in hardware and simulation.');

-- BSc Mathematics requirements
INSERT INTO course_requirements (course_id, subject_id, min_score, explanation) VALUES
    ((SELECT id FROM courses WHERE code = 'bsc-math'), (SELECT id FROM subjects WHERE code = 'math'), 7, 'Excellent mathematical ability is essential for advanced study.'),
    ((SELECT id FROM courses WHERE code = 'bsc-math'), (SELECT id FROM subjects WHERE code = 'english'), 5, 'Communication skills needed for presenting mathematical concepts.');

-- BEd Primary requirements
INSERT INTO course_requirements (course_id, subject_id, min_score, explanation) VALUES
    ((SELECT id FROM courses WHERE code = 'bed-primary'), (SELECT id FROM subjects WHERE code = 'english'), 6, 'Strong language skills for teaching literacy.'),
    ((SELECT id FROM courses WHERE code = 'bed-primary'), (SELECT id FROM subjects WHERE code = 'math'), 5, 'Numeracy skills required for teaching mathematics.'),
    ((SELECT id FROM courses WHERE code = 'bed-primary'), (SELECT id FROM subjects WHERE code = 'science'), 4, 'Basic science knowledge for general education.');

-- BBA requirements
INSERT INTO course_requirements (course_id, subject_id, min_score, explanation) VALUES
    ((SELECT id FROM courses WHERE code = 'bba'), (SELECT id FROM subjects WHERE code = 'english'), 6, 'Business communication and report writing skills.'),
    ((SELECT id FROM courses WHERE code = 'bba'), (SELECT id FROM subjects WHERE code = 'math'), 5, 'Numerical skills for finance and statistics.'),
    ((SELECT id FROM courses WHERE code = 'bba'), (SELECT id FROM subjects WHERE code = 'business_studies'), 5, 'Foundation in business concepts.');

-- BIT requirements
INSERT INTO course_requirements (course_id, subject_id, min_score, explanation) VALUES
    ((SELECT id FROM courses WHERE code = 'bit'), (SELECT id FROM subjects WHERE code = 'math'), 6, 'Logical thinking and problem-solving skills.'),
    ((SELECT id FROM courses WHERE code = 'bit'), (SELECT id FROM subjects WHERE code = 'english'), 5, 'Documentation and communication skills.'),
    ((SELECT id FROM courses WHERE code = 'bit'), (SELECT id FROM subjects WHERE code = 'computer_studies'), 5, 'Basic computing knowledge preferred.');

-- Verify the reset was successful
SELECT 'Database reset completed successfully. ' || COUNT(*) || ' courses loaded.' as status
FROM courses;