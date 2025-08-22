-- Lesotho Admissions Smart Calculator - Database Schema
-- Designed for LGCSE/ASC grading system and Lesotho universities

-- Enable UUID extension for user IDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Grade scale table for LGCSE/ASC grading system
CREATE TABLE grade_scale (
    id SERIAL PRIMARY KEY,
    curriculum TEXT NOT NULL CHECK (curriculum IN ('LGCSE', 'ASC')),
    grade_label TEXT NOT NULL,
    points INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(curriculum, grade_label)
);

-- 2. Universities table
CREATE TABLE universities (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    country TEXT DEFAULT 'Lesotho',
    website TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Faculties table
CREATE TABLE faculties (
    id SERIAL PRIMARY KEY,
    university_id INTEGER REFERENCES universities(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Courses table
CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    faculty_id INTEGER REFERENCES faculties(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    code TEXT NOT NULL,
    nqf_level INTEGER,
    duration_years INTEGER,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(faculty_id, code)
);

-- 5. Subjects table
CREATE TABLE subjects (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Subject aliases for common variants
CREATE TABLE subject_aliases (
    id SERIAL PRIMARY KEY,
    subject_id INTEGER REFERENCES subjects(id) ON DELETE CASCADE,
    alias TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(subject_id, alias)
);

-- 7. Course requirements with JSON rules
CREATE TABLE course_requirements (
    id SERIAL PRIMARY KEY,
    course_id INTEGER REFERENCES courses(id) ON DELETE CASCADE,
    rule_json JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Learners table (linked to Supabase auth users)
CREATE TABLE learners (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    school_name TEXT,
    grade TEXT CHECK (grade IN ('LGCSE', 'ASC')),
    intake_year INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Learner subjects and grades
CREATE TABLE learner_subjects (
    id SERIAL PRIMARY KEY,
    learner_id UUID REFERENCES learners(id) ON DELETE CASCADE,
    subject_id INTEGER REFERENCES subjects(id) ON DELETE CASCADE,
    grade_label TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(learner_id, subject_id)
);

-- 10. Matches table for storing results
CREATE TABLE matches (
    id SERIAL PRIMARY KEY,
    learner_id UUID REFERENCES learners(id) ON DELETE CASCADE,
    course_id INTEGER REFERENCES courses(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('Eligible', 'Borderline', 'Not eligible')),
    score INTEGER,
    explanation TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 11. Sessions table for user interactions
CREATE TABLE sessions (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    anon_id TEXT,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_active_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    device TEXT,
    app_version TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 12. Events table for analytics
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    session_id INTEGER REFERENCES sessions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    anon_id TEXT,
    event_type TEXT NOT NULL,
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    screen TEXT,
    context_json JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

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
('LGCSE', 'U', 0);

-- Insert ASC grade scale (example - adjust based on actual ASC grading)
INSERT INTO grade_scale (curriculum, grade_label, points) VALUES
('ASC', '1', 7),
('ASC', '2', 6),
('ASC', '3', 5),
('ASC', '4', 4),
('ASC', '5', 3),
('ASC', '6', 2),
('ASC', '7', 1),
('ASC', '8', 0);

-- Insert Lesotho universities
INSERT INTO universities (name, website) VALUES
('National University of Lesotho', 'https://www.nul.ls'),
('Limkokwing University of Creative Technology – Lesotho', 'https://www.limkokwing.co.ls');

-- Insert faculties for NUL
INSERT INTO faculties (university_id, name) VALUES
(1, 'Faculty of Science and Technology'),
(1, 'Faculty of Health Sciences'),
(1, 'Faculty of Humanities');

-- Insert faculties for Limkokwing
INSERT INTO faculties (university_id, name) VALUES
(2, 'Faculty of Design and Innovation'),
(2, 'Faculty of Information and Communication Technology'),
(2, 'Faculty of Business and Management');

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
('PS', 'Physical Science');

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
(14, 'Physical Science'), (14, 'PhySci');

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
(3, 'BA Sociology', 'SOC001', 6, 3, 'Bachelor of Arts in Sociology');

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
(6, 'BA Branding and Advertising', 'BA001', 6, 3, 'Bachelor of Arts in Branding and Advertising');

-- Insert course requirements (example rules in JSON format)
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
}');

-- Enable Row Level Security on all tables
ALTER TABLE learners ENABLE ROW LEVEL SECURITY;
ALTER TABLE learner_subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Policies for learners table
CREATE POLICY "Users can read own learner data" ON learners FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own learner data" ON learners FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own learner data" ON learners FOR UPDATE USING (auth.uid() = user_id);

-- Policies for learner_subjects table
CREATE POLICY "Users can read own learner subjects" ON learner_subjects FOR SELECT USING (learner_id IN (SELECT id FROM learners WHERE user_id = auth.uid()));
CREATE POLICY "Users can manage own learner subjects" ON learner_subjects FOR ALL USING (learner_id IN (SELECT id FROM learners WHERE user_id = auth.uid()));

-- Policies for matches table
CREATE POLICY "Users can read own matches" ON matches FOR SELECT USING (learner_id IN (SELECT id FROM learners WHERE user_id = auth.uid()));
CREATE POLICY "System can insert matches" ON matches FOR INSERT WITH CHECK (true);

-- Policies for sessions table
CREATE POLICY "Users can read own sessions" ON sessions FOR SELECT USING (user_id = auth.uid() OR anon_id IS NOT NULL);
CREATE POLICY "Anyone can insert sessions" ON sessions FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own sessions" ON sessions FOR UPDATE USING (user_id = auth.uid());

-- Policies for events table
CREATE POLICY "Users can read own events" ON events FOR SELECT USING (user_id = auth.uid() OR session_id IN (SELECT id FROM sessions WHERE anon_id IS NOT NULL));
CREATE POLICY "Anyone can insert events" ON events FOR INSERT WITH CHECK (true);

-- Public read access to reference data
ALTER TABLE grade_scale ENABLE ROW LEVEL SECURITY;
ALTER TABLE universities ENABLE ROW LEVEL SECURITY;
ALTER TABLE faculties ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE subject_aliases ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_requirements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can read grade_scale" ON grade_scale FOR SELECT USING (true);
CREATE POLICY "Public can read universities" ON universities FOR SELECT USING (true);
CREATE POLICY "Public can read faculties" ON faculties FOR SELECT USING (true);
CREATE POLICY "Public can read courses" ON courses FOR SELECT USING (true);
CREATE POLICY "Public can read subjects" ON subjects FOR SELECT USING (true);
CREATE POLICY "Public can read subject_aliases" ON subject_aliases FOR SELECT USING (true);
CREATE POLICY "Public can read course_requirements" ON course_requirements FOR SELECT USING (true);

-- Create indexes for performance
CREATE INDEX idx_learner_subjects_learner_id ON learner_subjects(learner_id);
CREATE INDEX idx_matches_learner_id ON matches(learner_id);
CREATE INDEX idx_events_session_id ON events(session_id);
CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_anon_id ON sessions(anon_id);

SELECT 'Lesotho MVP database schema created successfully with sample data!' AS result;