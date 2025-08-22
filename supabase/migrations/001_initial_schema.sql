-- Universities table
CREATE TABLE universities (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    description TEXT,
    website_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Faculties table
CREATE TABLE faculties (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    university_id UUID REFERENCES universities(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    code TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Subjects table
CREATE TABLE subjects (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    code TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Courses table
CREATE TABLE courses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    faculty_id UUID REFERENCES faculties(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    code TEXT NOT NULL,
    duration TEXT,
    description TEXT,
    total_aps_required INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Course requirements table
CREATE TABLE course_requirements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE,
    min_score INTEGER NOT NULL,
    explanation TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Grade mappings table (configurable LGCSE grading system)
CREATE TABLE grade_mappings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    grade TEXT NOT NULL,
    points INTEGER NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Learners table (extends Supabase auth.users)
CREATE TABLE learners (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    date_of_birth DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Learner scores table
CREATE TABLE learner_scores (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    learner_id UUID REFERENCES learners(id) ON DELETE CASCADE,
    subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE,
    score INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sessions table for analytics
CREATE TABLE sessions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    learner_id UUID REFERENCES learners(id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ended_at TIMESTAMP WITH TIME ZONE,
    ip_address TEXT,
    user_agent TEXT
);

-- Events table for user behavior tracking
CREATE TABLE events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,
    event_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_faculties_university_id ON faculties(university_id);
CREATE INDEX idx_courses_faculty_id ON courses(faculty_id);
CREATE INDEX idx_course_requirements_course_id ON course_requirements(course_id);
CREATE INDEX idx_course_requirements_subject_id ON course_requirements(subject_id);
CREATE INDEX idx_learner_scores_learner_id ON learner_scores(learner_id);
CREATE INDEX idx_learner_scores_subject_id ON learner_scores(subject_id);
CREATE INDEX idx_sessions_learner_id ON sessions(learner_id);
CREATE INDEX idx_events_session_id ON events(session_id);

-- Enable Row Level Security (RLS) on all tables
ALTER TABLE universities ENABLE ROW LEVEL SECURITY;
ALTER TABLE faculties ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_requirements ENABLE ROW LEVEL SECURITY;
ALTER TABLE grade_mappings ENABLE ROW LEVEL SECURITY;
ALTER TABLE learners ENABLE ROW LEVEL SECURITY;
ALTER TABLE learner_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Universities: Readable by all
CREATE POLICY "Universities are viewable by everyone" ON universities
    FOR SELECT USING (true);

-- Faculties: Readable by all
CREATE POLICY "Faculties are viewable by everyone" ON faculties
    FOR SELECT USING (true);

-- Subjects: Readable by all
CREATE POLICY "Subjects are viewable by everyone" ON subjects
    FOR SELECT USING (true);

-- Courses: Readable by all
CREATE POLICY "Courses are viewable by everyone" ON courses
    FOR SELECT USING (true);

-- Course requirements: Readable by all
CREATE POLICY "Course requirements are viewable by everyone" ON course_requirements
    FOR SELECT USING (true);

-- Grade mappings: Readable by all
CREATE POLICY "Grade mappings are viewable by everyone" ON grade_mappings
    FOR SELECT USING (true);

-- Learners: Users can only see their own data
CREATE POLICY "Learners can view own data" ON learners
    FOR SELECT USING (auth.uid() = id);

-- Learner scores: Users can only see their own scores
CREATE POLICY "Learner scores can view own data" ON learner_scores
    FOR SELECT USING (auth.uid() = learner_id);

-- Sessions: Users can only see their own sessions
CREATE POLICY "Sessions can view own data" ON sessions
    FOR SELECT USING (auth.uid() = learner_id);

-- Events: Users can only see their own events
CREATE POLICY "Events can view own data" ON events
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM sessions 
        WHERE sessions.id = events.session_id 
        AND sessions.learner_id = auth.uid()
    ));

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

-- Create a function to calculate total APS for a learner
CREATE OR REPLACE FUNCTION calculate_learner_aps(learner_id UUID)
RETURNS INTEGER AS $$
BEGIN
    RETURN COALESCE((
        SELECT SUM(ls.score)
        FROM learner_scores ls
        WHERE ls.learner_id = calculate_learner_aps.learner_id
    ), 0);
END;
$$ LANGUAGE plpgsql;

-- Create a function to check course eligibility with explanations
CREATE OR REPLACE FUNCTION check_course_eligibility(learner_id UUID, course_id UUID)
RETURNS TABLE(requirement_met BOOLEAN, subject_name TEXT, min_score INTEGER, learner_score INTEGER, explanation TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(ls.score, 0) >= cr.min_score AS requirement_met,
        s.name AS subject_name,
        cr.min_score,
        COALESCE(ls.score, 0) AS learner_score,
        cr.explanation
    FROM course_requirements cr
    JOIN subjects s ON cr.subject_id = s.id
    LEFT JOIN learner_scores ls ON ls.subject_id = s.id AND ls.learner_id = check_course_eligibility.learner_id
    WHERE cr.course_id = check_course_eligibility.course_id;
END;
$$ LANGUAGE plpgsql;