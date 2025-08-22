-- Test data for match-programs Edge Function
-- Insert a test learner and subjects to test the matching engine

-- First, ensure we have a user in auth.users (if not already exists)
-- Note: In production, users are created through Supabase Auth signup
-- For testing, we can create a user directly (requires service role key)

-- Insert a test learner (assuming user exists or we use a dummy UUID)
INSERT INTO learners (id, user_id, full_name, school_name, grade, intake_year) VALUES
(
  '12345678-1234-1234-1234-123456789012',
  '12345678-1234-1234-1234-123456789012',
  'Test Learner',
  'Test High School',
  'LGCSE',
  2025
)
ON CONFLICT (id) DO NOTHING;

-- Insert test subjects for the learner
INSERT INTO learner_subjects (learner_id, subject_id, grade_label) VALUES
-- Mathematics - Grade B (6 points)
('12345678-1234-1234-1234-123456789012', (SELECT id FROM subjects WHERE code = 'MATH'), 'B'),
-- English - Grade C (5 points)
('12345678-1234-1234-1234-123456789012', (SELECT id FROM subjects WHERE code = 'ENG'), 'C'),
-- Physics - Grade C (5 points)
('12345678-1234-1234-1234-123456789012', (SELECT id FROM subjects WHERE code = 'PHY'), 'C'),
-- Chemistry - Grade D (4 points)
('12345678-1234-1234-1234-123456789012', (SELECT id FROM subjects WHERE code = 'CHEM'), 'D'),
-- Biology - Grade C (5 points)
('12345678-1234-1234-1234-123456789012', (SELECT id FROM subjects WHERE code = 'BIO'), 'C')
ON CONFLICT (learner_id, subject_id) DO UPDATE SET grade_label = EXCLUDED.grade_label;

-- Verify the test data
SELECT 
  l.full_name,
  s.code as subject_code,
  s.name as subject_name,
  ls.grade_label,
  gs.points
FROM learners l
JOIN learner_subjects ls ON l.id = ls.learner_id
JOIN subjects s ON ls.subject_id = s.id
JOIN grade_scale gs ON ls.grade_label = gs.grade_label AND gs.curriculum = 'LGCSE'
WHERE l.id = '12345678-1234-1234-1234-123456789012';

-- Calculate total aggregate points
SELECT 
  l.full_name,
  SUM(gs.points) as total_points
FROM learners l
JOIN learner_subjects ls ON l.id = ls.learner_id
JOIN subjects s ON ls.subject_id = s.id
JOIN grade_scale gs ON ls.grade_label = gs.grade_label AND gs.curriculum = 'LGCSE'
WHERE l.id = '12345678-1234-1234-1234-123456789012'
GROUP BY l.full_name;