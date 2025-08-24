-- Populate Essential Data for University Matcher
-- This script only inserts data, assuming tables already exist

-- Insert LGCSE grade scale
INSERT INTO grade_scale (curriculum, grade_label, points) VALUES
('LGCSE', 'A*', 8),
('LGCSE', 'A', 7),
('LGCSE', 'B', 6),
('LGCSE', 'C', 5),
('LGCSE', 'D', 4),
('LGCSE', 'E', 3),
('LGCSE', 'F', 2),
('LGCSE', 'G', 1),
('LGCSE', 'U', 0)
ON CONFLICT (curriculum, grade_label) DO NOTHING;

-- Insert ASC grade scale
INSERT INTO grade_scale (curriculum, grade_label, points) VALUES
('ASC', '1', 7),
('ASC', '2', 6),
('ASC', '3', 5),
('ASC', '4', 4),
('ASC', '5', 3),
('ASC', '6', 2),
('ASC', '7', 1),
('ASC', '8', 0)
ON CONFLICT (curriculum, grade_label) DO NOTHING;

-- Insert Lesotho universities
INSERT INTO universities (name, website) VALUES
('National University of Lesotho', 'https://www.nul.ls'),
('Limkokwing University of Creative Technology – Lesotho', 'https://www.limkokwing.co.ls')
ON CONFLICT (name) DO NOTHING;

-- Insert faculties for NUL
INSERT INTO faculties (university_id, name) VALUES
(1, 'Faculty of Science and Technology'),
(1, 'Faculty of Health Sciences'),
(1, 'Faculty of Humanities')
ON CONFLICT (university_id, name) DO NOTHING;

-- Insert faculties for Limkokwing
INSERT INTO faculties (university_id, name) VALUES
(2, 'Faculty of Design and Innovation'),
(2, 'Faculty of Information and Communication Technology'),
(2, 'Faculty of Business and Management')
ON CONFLICT (university_id, name) DO NOTHING;

-- Insert common subjects
INSERT INTO subjects (code, name) VALUES
('MATH', 'Mathematics'),
('ENG', 'English'),
('PHY', 'Physics'),
('CHEM', 'Chemistry'),
('BIO', 'Biology'),
('HIST', 'History'),
('GEO', 'Geography'),
('ECON', 'Economics'),
('ACC', 'Accounting'),
('ICT', 'Information Technology'),
('ART', 'Art'),
('SES', 'Sesotho'),
('FOOD', 'Food and Nutrition'),
('PS', 'Physical Science')
ON CONFLICT (code) DO NOTHING;

-- Insert subject aliases for common variants
INSERT INTO subject_aliases (subject_id, alias) VALUES
(1, 'Maths'), (1, 'Math'), (1, 'Mathematics Core'),
(2, 'English Language'), (2, 'English First Language'), (2, 'EFL'),
(3, 'Physical Sciences'), (3, 'Physics & Chemistry'), (3, 'PhySci'),
(4, 'Chemistry'), (5, 'Biological Science'), (5, 'Bio'), (5, 'Life Science'),
(6, 'History'), (6, 'History Modern'), (6, 'History Ancient'),
(7, 'Geography'), (7, 'Geog'), (7, 'Human Geography'), (7, 'Physical Geography'),
(8, 'Economics'), (9, 'Principles of Accounts'), (9, 'POA'), (9, 'Acc'),
(10, 'IT'), (10, 'Computer Science'), (10, 'Computing'), (10, 'ICT'),
(11, 'Art'), (11, 'Design'),
(12, 'Sesotho'), (12, 'Sotho'), (12, 'Southern Sotho'), (12, 'Sesotho Language'),
(13, 'Food and Nutrition'), (13, 'Food Science'),
(14, 'Physical Science'), (14, 'PhySci')
ON CONFLICT (subject_id, alias) DO NOTHING;

-- Insert courses for NUL
INSERT INTO courses (faculty_id, name, code, nqf_level, duration_years, notes) VALUES
-- Faculty of Science and Technology (NUL)
(1, 'BSc Computer Science', 'CS001', 6, 4, 'Bachelor of Science in Computer Science'),
(1, 'BSc Mathematics', 'MATH001', 6, 3, 'Bachelor of Science in Mathematics'),
(1, 'BSc Physics', 'PHY001', 6, 3, 'Bachelor of Science in Physics'),
(1, 'BSc Chemistry', 'CHEM001', 6, 3, 'Bachelor of Science in Chemistry'),
(1, 'BEng Civil Engineering', 'CE001', 6, 4, 'Bachelor of Engineering in Civil Engineering'),
(1, 'BSc Food Science and Technology', 'FST001', 6, 3, 'Bachelor of Science in Food Science and Technology'),
-- Faculty of Health Sciences (NUL)
(2, 'Bachelor of Nursing Science', 'BNS001', 6, 4, 'Bachelor of Nursing Science'),
(2, 'Bachelor of Pharmacy', 'BPharm001', 6, 4, 'Bachelor of Pharmacy'),
(2, 'BSc Public Health', 'BSPH001', 6, 3, 'Bachelor of Science in Public Health'),
(2, 'BSc Nutrition and Dietetics', 'BND001', 6, 3, 'Bachelor of Science in Nutrition and Dietetics'),
-- Faculty of Humanities (NUL)
(3, 'BA English', 'ENG001', 6, 3, 'Bachelor of Arts in English'),
(3, 'BA History', 'HIST001', 6, 3, 'Bachelor of Arts in History'),
(3, 'BA Demography', 'DEM001', 6, 3, 'Bachelor of Arts in Demography'),
(3, 'BA Development Studies', 'DEV001', 6, 3, 'Bachelor of Arts in Development Studies'),
(3, 'BA Media Studies', 'MED001', 6, 3, 'Bachelor of Arts in Media Studies'),
(3, 'BA Sociology', 'SOC001', 6, 3, 'Bachelor of Arts in Sociology')
ON CONFLICT (faculty_id, code) DO NOTHING;

-- Insert courses for Limkokwing
INSERT INTO courses (faculty_id, name, code, nqf_level, duration_years, notes) VALUES
-- Faculty of Design and Innovation (Limkokwing)
(4, 'BA Graphic Design', 'GD001', 6, 3, 'Bachelor of Arts in Graphic Design'),
(4, 'BA Fashion Design', 'FD001', 6, 3, 'Bachelor of Arts in Fashion Design'),
(4, 'BA Interior Architecture', 'IA001', 6, 3, 'Bachelor of Arts in Interior Architecture'),
(4, 'BA Animation', 'ANIM001', 6, 3, 'Bachelor of Arts in Animation'),
(4, 'BA Multimedia Design', 'MMD001', 6, 3, 'Bachelor of Arts in Multimedia Design'),
-- Faculty of Information and Communication Technology (Limkokwing)
(5, 'BSc Software Engineering', 'SE001', 6, 4, 'Bachelor of Science in Software Engineering'),
(5, 'BSc Information Technology', 'IT001', 6, 3, 'Bachelor of Science in Information Technology'),
(5, 'BSc Cyber Security', 'CSEC001', 6, 3, 'Bachelor of Science in Cyber Security'),
(5, 'BSc Business Information Systems', 'BIS001', 6, 3, 'Bachelor of Science in Business Information Systems'),
(5, 'BSc Data Analytics', 'DA001', 6, 3, 'Bachelor of Science in Data Analytics'),
-- Faculty of Business and Management (Limkokwing)
(6, 'BBA Business Administration', 'BBA001', 6, 3, 'Bachelor of Business Administration'),
(6, 'BA Retail Management', 'RM001', 6, 3, 'Bachelor of Arts in Retail Management'),
(6, 'BA Tourism Management', 'TM001', 6, 3, 'Bachelor of Arts in Tourism Management'),
(6, 'BA Public Relations', 'PR001', 6, 3, 'Bachelor of Arts in Public Relations'),
(6, 'BA Branding and Advertising', 'BA001', 6, 3, 'Bachelor of Arts in Branding and Advertising')
ON CONFLICT (faculty_id, code) DO NOTHING;

-- Insert course requirements
INSERT INTO course_requirements (course_id, rule_json) VALUES
-- NUL Computer Science
(1, '{
  "min_aggregate_points": 32,
  "required_subjects": [
    {"subject": "Mathematics", "min_grade": "B"},
    {"subject": "English", "min_grade": "C"}
  ],
  "required_combinations": [
    {
      "type": "at_least_one_of",
      "subjects": ["Physical Science", "Physics", "Computer Studies"],
      "min_grade": "C"
    }
  ],
  "notes": "Extremely competitive. Actual cut-off is often higher than the minimum."
}'),
-- NUL Bachelor of Nursing Science
(7, '{
  "min_aggregate_points": 32,
  "required_subjects": [
    {"subject": "Biology", "min_grade": "C"},
    {"subject": "Chemistry", "min_grade": "C"},
    {"subject": "English", "min_grade": "C"},
    {"subject": "Mathematics", "min_grade": "D"}
  ],
  "notes": "Limited seats. Requires a clean criminal record and medical fitness."
}'),
-- NUL Bachelor of Pharmacy
(8, '{
  "min_aggregate_points": 35,
  "required_subjects": [
    {"subject": "Biology", "min_grade": "B"},
    {"subject": "Chemistry", "min_grade": "B"},
    {"subject": "Physics", "min_grade": "C"},
    {"subject": "Mathematics", "min_grade": "C"}
  ],
  "notes": "Very competitive program with limited intake capacity."
}'),
-- Limkokwing BA Graphic Design
(13, '{
  "min_aggregate_points": 24,
  "required_subjects": [
    {"subject": "English", "min_grade": "C"}
  ],
  "optional_subjects": [
    {"subject": "Art", "min_grade": "C", "is_advantage": true}
  ],
  "notes": "A portfolio of creative work is required during the application process."
}'),
-- Limkokwing BSc Software Engineering
(18, '{
  "min_aggregate_points": 26,
  "required_subjects": [
    {"subject": "Mathematics", "min_grade": "D"},
    {"subject": "English", "min_grade": "C"}
  ],
  "notes": "Mathematics and IT subjects preferred. Interest in computing is essential."
}'),
-- Limkokwing BBA Business Administration
(23, '{
  "min_aggregate_points": 25,
  "required_subjects": [
    {"subject": "Mathematics", "min_grade": "D"},
    {"subject": "English", "min_grade": "C"}
  ],
  "notes": "Good communication skills and business aptitude required."
}')
ON CONFLICT (course_id) DO NOTHING;

SELECT 'Data populated successfully!' AS result;