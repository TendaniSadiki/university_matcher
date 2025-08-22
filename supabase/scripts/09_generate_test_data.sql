-- Test Data Generation: Sample Learner Profiles and Scores
-- Usage: Run this script in Supabase SQL Editor after creating test user accounts
-- Ensure test users exist in auth.users with these emails before running

-- Sample Learner 1: High Achiever (Excellent scores across all subjects)
UPDATE learners SET 
    first_name = 'Thabo',
    last_name = 'Mokoena',
    date_of_birth = '2005-03-15'
WHERE id = (SELECT id FROM auth.users WHERE email = 'thabo.mokoena@example.com');

INSERT INTO learner_scores (learner_id, subject_id, score)
SELECT 
    l.id as learner_id,
    s.id as subject_id,
    CASE s.code
        WHEN 'math' THEN 9
        WHEN 'english' THEN 9
        WHEN 'science' THEN 9
        WHEN 'sesotho' THEN 8
        WHEN 'physics' THEN 9
        WHEN 'chemistry' THEN 9
        WHEN 'biology' THEN 8
        WHEN 'accounting' THEN 8
        WHEN 'computer_studies' THEN 9
        ELSE 7
    END as score
FROM learners l
CROSS JOIN subjects s
WHERE l.id = (SELECT id FROM auth.users WHERE email = 'thabo.mokoena@example.com')
AND s.code IN ('math', 'english', 'science', 'sesotho', 'physics', 'chemistry', 'biology', 'accounting', 'computer_studies')
ON CONFLICT (learner_id, subject_id) 
DO UPDATE SET score = EXCLUDED.score;

-- Sample Learner 2: Average Achiever (Good scores with some variations)
UPDATE learners SET 
    first_name = 'Lerato',
    last_name = 'Moloi',
    date_of_birth = '2005-07-22'
WHERE id = (SELECT id FROM auth.users WHERE email = 'lerato.moloi@example.com');

INSERT INTO learner_scores (learner_id, subject_id, score)
SELECT 
    l.id as learner_id,
    s.id as subject_id,
    CASE s.code
        WHEN 'math' THEN 7
        WHEN 'english' THEN 8
        WHEN 'science' THEN 6
        WHEN 'sesotho' THEN 9
        WHEN 'history' THEN 7
        WHEN 'geography' THEN 7
        WHEN 'economics' THEN 6
        WHEN 'business_studies' THEN 7
        ELSE 5
    END as score
FROM learners l
CROSS JOIN subjects s
WHERE l.id = (SELECT id FROM auth.users WHERE email = 'lerato.moloi@example.com')
AND s.code IN ('math', 'english', 'science', 'sesotho', 'history', 'geography', 'economics', 'business_studies')
ON CONFLICT (learner_id, subject_id) 
DO UPDATE SET score = EXCLUDED.score;

-- Sample Learner 3: STEM Focused (Strong in science/math, weaker in languages)
UPDATE learners SET 
    first_name = 'David',
    last_name = 'Nkosi',
    date_of_birth = '2005-11-08'
WHERE id = (SELECT id FROM auth.users WHERE email = 'david.nkosi@example.com');

INSERT INTO learner_scores (learner_id, subject_id, score)
SELECT 
    l.id as learner_id,
    s.id as subject_id,
    CASE s.code
        WHEN 'math' THEN 9
        WHEN 'physics' THEN 9
        WHEN 'chemistry' THEN 8
        WHEN 'biology' THEN 8
        WHEN 'computer_studies' THEN 9
        WHEN 'english' THEN 5
        WHEN 'sesotho' THEN 4
        WHEN 'history' THEN 6
        ELSE 5
    END as score
FROM learners l
CROSS JOIN subjects s
WHERE l.id = (SELECT id FROM auth.users WHERE email = 'david.nkosi@example.com')
AND s.code IN ('math', 'english', 'sesotho', 'physics', 'chemistry', 'biology', 'computer_studies', 'history')
ON CONFLICT (learner_id, subject_id) 
DO UPDATE SET score = EXCLUDED.score;

-- Sample Learner 4: Arts/Humanities Focused (Strong in languages/humanities, weaker in STEM)
UPDATE learners SET 
    first_name = 'Mpho',
    last_name = 'Dlamini',
    date_of_birth = '2005-01-30'
WHERE id = (SELECT id FROM auth.users WHERE email = 'mpho.dlamini@example.com');

INSERT INTO learner_scores (learner_id, subject_id, score)
SELECT 
    l.id as learner_id,
    s.id as subject_id,
    CASE s.code
        WHEN 'english' THEN 8
        WHEN 'sesotho' THEN 9
        WHEN 'history' THEN 8
        WHEN 'geography' THEN 7
        WHEN 'religious_studies' THEN 8
        WHEN 'art_design' THEN 7
        WHEN 'math' THEN 4
        WHEN 'science' THEN 5
        ELSE 6
    END as score
FROM learners l
CROSS JOIN subjects s
WHERE l.id = (SELECT id FROM auth.users WHERE email = 'mpho.dlamini@example.com')
AND s.code IN ('math', 'english', 'science', 'sesotho', 'history', 'geography', 'religious_studies', 'art_design')
ON CONFLICT (learner_id, subject_id) 
DO UPDATE SET score = EXCLUDED.score;

-- Sample Learner 5: Borderline Candidate (Meets minimum requirements for some courses)
UPDATE learners SET 
    first_name = 'Tumelo',
    last_name = 'Khumalo',
    date_of_birth = '2005-09-14'
WHERE id = (SELECT id FROM auth.users WHERE email = 'tumelo.khumalo@example.com');

INSERT INTO learner_scores (learner_id, subject_id, score)
SELECT 
    l.id as learner_id,
    s.id as subject_id,
    CASE s.code
        WHEN 'math' THEN 6
        WHEN 'english' THEN 6
        WHEN 'science' THEN 5
        WHEN 'sesotho' THEN 7
        WHEN 'business_studies' THEN 6
        WHEN 'accounting' THEN 5
        ELSE 4
    END as score
FROM learners l
CROSS JOIN subjects s
WHERE l.id = (SELECT id FROM auth.users WHERE email = 'tumelo.khumalo@example.com')
AND s.code IN ('math', 'english', 'science', 'sesotho', 'business_studies', 'accounting')
ON CONFLICT (learner_id, subject_id) 
DO UPDATE SET score = EXCLUDED.score;

-- Verify the test data was inserted correctly
SELECT 
    u.email,
    l.first_name,
    l.last_name,
    COUNT(ls.id) as subject_count,
    calculate_learner_aps(l.id) as total_aps
FROM learners l
JOIN auth.users u ON l.id = u.id
LEFT JOIN learner_scores ls ON l.id = ls.learner_id
WHERE u.email IN (
    'thabo.mokoena@example.com',
    'lerato.moloi@example.com',
    'david.nkosi@example.com',
    'mpho.dlamini@example.com',
    'tumelo.khumalo@example.com'
)
GROUP BY u.email, l.first_name, l.last_name, l.id
ORDER BY total_aps DESC;

-- View detailed scores for all test learners
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
WHERE u.email IN (
    'thabo.mokoena@example.com',
    'lerato.moloi@example.com',
    'david.nkosi@example.com',
    'mpho.dlamini@example.com',
    'tumelo.khumalo@example.com'
)
ORDER BY u.email, s.name;