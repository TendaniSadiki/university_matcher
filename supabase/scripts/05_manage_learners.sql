-- Admin Script: Manage Learners and Scores
-- Usage: Run this script in Supabase SQL Editor to manage learner data and their scores

-- Note: Learners are automatically created when users sign up via Supabase Auth
-- This script focuses on managing learner profiles and their academic scores

-- Update learner profile information
UPDATE learners SET 
    first_name = 'UpdatedFirstName',
    last_name = 'UpdatedLastName',
    date_of_birth = '2000-01-01'
WHERE id = (SELECT id FROM auth.users WHERE email = 'learner@example.com');

-- Add or update learner scores for specific subjects
INSERT INTO learner_scores (learner_id, subject_id, score)
SELECT 
    l.id as learner_id,
    s.id as subject_id,
    8 as score -- A grade in points
FROM learners l
CROSS JOIN subjects s
WHERE l.id = (SELECT id FROM auth.users WHERE email = 'learner@example.com')
AND s.code IN ('math', 'english', 'science')
ON CONFLICT (learner_id, subject_id) 
DO UPDATE SET score = EXCLUDED.score;

-- Delete specific learner scores
DELETE FROM learner_scores 
WHERE learner_id = (SELECT id FROM auth.users WHERE email = 'learner@example.com')
AND subject_id = (SELECT id FROM subjects WHERE code = 'art_design');

-- List all learners with their basic information
SELECT 
    u.email,
    l.first_name,
    l.last_name,
    l.date_of_birth,
    COUNT(ls.id) as subject_count,
    calculate_learner_aps(l.id) as total_aps
FROM learners l
JOIN auth.users u ON l.id = u.id
LEFT JOIN learner_scores ls ON l.id = ls.learner_id
GROUP BY u.email, l.first_name, l.last_name, l.date_of_birth, l.id
ORDER BY l.last_name, l.first_name;

-- View detailed scores for a specific learner
SELECT 
    u.email,
    l.first_name,
    l.last_name,
    s.name as subject_name,
    s.code as subject_code,
    ls.score,
    gm.grade,
    gm.description as grade_description
FROM learners l
JOIN auth.users u ON l.id = u.id
JOIN learner_scores ls ON l.id = ls.learner_id
JOIN subjects s ON ls.subject_id = s.id
LEFT JOIN grade_mappings gm ON ls.score = gm.points
WHERE u.email = 'learner@example.com'
ORDER BY s.name;

-- Calculate APS breakdown for a learner
SELECT 
    s.name as subject,
    ls.score,
    gm.grade,
    gm.description as grade_description
FROM learner_scores ls
JOIN subjects s ON ls.subject_id = s.id
LEFT JOIN grade_mappings gm ON ls.score = gm.points
WHERE ls.learner_id = (SELECT id FROM auth.users WHERE email = 'learner@example.com')
ORDER BY s.name;

-- Delete a learner and all associated data (use with extreme caution)
-- This will cascade delete learner_scores, sessions, and events
-- DELETE FROM learners WHERE id = (SELECT id FROM auth.users WHERE email = 'learner@example.com');